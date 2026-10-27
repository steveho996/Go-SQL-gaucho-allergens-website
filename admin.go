package main

import (
	"crypto/subtle"
	"html/template"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
)

var tpl = template.Must(template.ParseGlob("templates/*.html"))

func basicAuth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		_, pass, ok := r.BasicAuth()
		want := os.Getenv("ADMIN_PASSWORD")
		if want == "" || !ok || subtle.ConstantTimeCompare([]byte(pass), []byte(want)) != 1 {
			w.Header().Set("WWW-Authenticate", `Basic realm="Chef"`)
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}
		next(w, r)
	}
}

type AdminItem struct {
	ID      int
	Name    string
	Section string
	Vege    bool
	Mode    string // unknown | none | has
	Summary string
}

type SectionGroup struct {
	Section string
	Items   []AdminItem
}

func modeOf(contain []string) (string, string) {
	switch {
	case contain == nil:
		return "unknown", "Not checked"
	case len(contain) == 0:
		return "none", "No allergens"
	default:
		return "has", strings.Join(contain, ", ")
	}
}

func handleAdminList(w http.ResponseWriter, r *http.Request) {
	rows, err := pool.Query(r.Context(),
		`SELECT id, name, section, vege, contain FROM items ORDER BY section, name`)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()

	var groups []SectionGroup
	for rows.Next() {
		var it AdminItem
		var contain []string
		if err := rows.Scan(&it.ID, &it.Name, &it.Section, &it.Vege, &contain); err != nil {
			http.Error(w, err.Error(), 500)
			return
		}
		it.Mode, it.Summary = modeOf(contain)
		if len(groups) == 0 || groups[len(groups)-1].Section != it.Section {
			groups = append(groups, SectionGroup{Section: it.Section})
		}
		g := &groups[len(groups)-1]
		g.Items = append(g.Items, it)
	}
	if err := tpl.ExecuteTemplate(w, "admin_list.html", groups); err != nil {
		log.Println(err)
	}
}

type AllergenBox struct {
	Code, Name string
	Checked    bool
}

type EditData struct {
	Item      AdminItem
	Allergens []AllergenBox
}

func handleEditForm(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}
	var it AdminItem
	var contain []string
	err = pool.QueryRow(r.Context(),
		`SELECT id, name, section, vege, contain FROM items WHERE id=$1`, id).
		Scan(&it.ID, &it.Name, &it.Section, &it.Vege, &contain)
	if err != nil {
		http.NotFound(w, r)
		return
	}
	it.Mode, it.Summary = modeOf(contain)

	have := map[string]bool{}
	for _, c := range contain {
		have[c] = true
	}
	rows, err := pool.Query(r.Context(), `SELECT code, name FROM allergens ORDER BY name`)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	defer rows.Close()
	data := EditData{Item: it}
	for rows.Next() {
		var a AllergenBox
		rows.Scan(&a.Code, &a.Name)
		a.Checked = have[a.Code]
		data.Allergens = append(data.Allergens, a)
	}
	if err := tpl.ExecuteTemplate(w, "admin_edit.html", data); err != nil {
		log.Println(err)
	}
}

func handleEditSave(w http.ResponseWriter, r *http.Request) {
	id, err := strconv.Atoi(r.PathValue("id"))
	if err != nil {
		http.NotFound(w, r)
		return
	}
	if err := r.ParseForm(); err != nil {
		http.Error(w, "bad form", 400)
		return
	}
	var contain []string // nil = NULL = unknown
	switch r.FormValue("status") {
	case "unknown":
	case "none":
		contain = []string{}
	case "has":
		contain = r.Form["codes"]
		if len(contain) == 0 {
			http.Error(w, "Pick at least one allergen, or choose 'No allergens'.", 400)
			return
		}
	default:
		http.Error(w, "bad status", 400)
		return
	}
	vege := r.FormValue("vege") == "on"

	_, err = pool.Exec(r.Context(),
		`UPDATE items SET contain=$1, vege=$2 WHERE id=$3`, contain, vege, id)
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	http.Redirect(w, r, "/admin", http.StatusSeeOther)
}