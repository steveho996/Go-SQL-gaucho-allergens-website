package main

import (
	"context"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Item struct {
	Name    string `json:"name"`
	Section string `json:"section"`
	Vege    bool   `json:"vege"`
}

type Response struct {
	Cannot  map[string][]Item `json:"cannot"`
	Can     map[string][]Item `json:"can"`
	Unknown map[string][]Item `json:"unknown"`
}

var pool *pgxpool.Pool

func main() {
	var err error
	pool, err = pgxpool.New(context.Background(), os.Getenv("DATABASE_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	http.HandleFunc("/api/allergens", handleAllergens)
	http.HandleFunc("/api/check", handleCheck)
	http.Handle("/", http.FileServer(http.Dir("./static")))

	http.HandleFunc("GET /admin", basicAuth(handleAdminList))
	http.HandleFunc("GET /admin/items/{id}", basicAuth(handleEditForm))
	http.HandleFunc("POST /admin/items/{id}", basicAuth(handleEditSave))

	http.HandleFunc("GET /waiter", func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, "static/waiter.html")
	})

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Println("listening on :" + port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

// GET /api/allergens -> list of code + name for the buttons
func handleAllergens(w http.ResponseWriter, r *http.Request) {
	rows, err := pool.Query(r.Context(), `SELECT code, name FROM allergens ORDER BY name`)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()

	type A struct{ Code, Name string }
	var out []A
	for rows.Next() {
		var a A
		if err := rows.Scan(&a.Code, &a.Name); err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		out = append(out, a)
	}
	json.NewEncoder(w).Encode(out)
}

// GET /api/check?a=ND,gluten
func handleCheck(w http.ResponseWriter, r *http.Request) {
	var inputs []string
	for _, s := range strings.Split(r.URL.Query().Get("a"), ",") {
		if s = strings.TrimSpace(s); s != "" {
			inputs = append(inputs, strings.ToLower(s))
		}
	}
	if len(inputs) == 0 {
		http.Error(w, "no allergen given", 400)
		return
	}

	// 1. resolve codes or full names to codes
	crow, err := pool.Query(r.Context(),
		`SELECT code FROM allergens WHERE lower(code) = ANY($1) OR lower(name) = ANY($1)`, inputs)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	var codes []string
	for crow.Next() {
		var c string
		crow.Scan(&c)
		codes = append(codes, c)
	}
	crow.Close()
	if len(codes) == 0 {
		http.Error(w, "unknown allergen", 400)
		return
	}

	// 2. classify every item
	rows, err := pool.Query(r.Context(), `
		SELECT section, name, vege,
		  CASE WHEN contain IS NULL THEN 'UNKNOWN'
		       WHEN contain && $1::text[] THEN 'CANNOT'
		       ELSE 'CAN' END
		FROM items ORDER BY section, name`, codes)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()

	res := Response{map[string][]Item{}, map[string][]Item{}, map[string][]Item{}}
	for rows.Next() {
		var it Item
		var verdict string
		if err := rows.Scan(&it.Section, &it.Name, &it.Vege, &verdict); err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		switch verdict {
		case "CANNOT":
			res.Cannot[it.Section] = append(res.Cannot[it.Section], it)
		case "CAN":
			res.Can[it.Section] = append(res.Can[it.Section], it)
		default:
			res.Unknown[it.Section] = append(res.Unknown[it.Section], it)
		}
	}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(res)
}
