**Author:** Duc Ho
**Period:** 26–29 October 2026
**Status:** Sold to client
**Live site: https://gaucho-allergens.onrender.com**

**Pitch file:** 

Allergen_Menu_Pitch.pdf

## 1. Goal and requirements

As a Senior Passador in Gaucho I see the pain point that waiters/passador at Gaucho Helsinki need a quick way to see which menu items they must not serve to a customer with a given allergy.

- Item names come from the menu PDF (Gaucho Menu, September 2026, about 87 items in 9 sections).
- The chef adds the allergen information later.
- Tech stack required: Go and SQL (PostgreSQL).
- Two roles: Waiter (read only) and Chef (edit, password protected).
- Visual design based on the restaurant's own colors.

## 2. Design decisions

| Decision | Choice | Reason |
| --- | --- | --- |
| Database | PostgreSQL, 2 tables | Simple, matches the brief |
| `allergens` table | `code` (primary key), `name` (unique) | Short codes for fast tapping |
| `items` table | `id`, `name`, `section`, `contain` (text array), `vege` | Allergen list stored directly on the item |
| Unknown data | `contain = NULL` means "not checked" | Safety rule, see below |
| Backend | Go (`net/http`, `pgx`, `html/template`) | Required language |
| Frontend | Plain HTML, CSS and JavaScript | No framework needed for a beginner project |

**Safety rule for `contain`:**

- `NULL` means the chef has not checked the item. It shows as "Ask the kitchen" and is never shown as safe.
- `{}` means the chef checked it and it has no allergens.
- `{ND,GF}` means it contains those allergens and must be avoided.

**Allergen codes:** AP - Apple, BE - Beans, PEP - Black Pepper, CA - Carrot, CE - Celery, CHI - Chili, CI - Citrus, ND - Dairy, EG - Egg, NF - Fish, GA - Garlic, GF - Gluten, MO - Molluscs, MU - Mushroom, MUS - Mustard, OIL - Oil, ON - Onion, PAP - Paprika, NP - Pork, NRM - Red meat, NSF - Seafood, SE - Seed, SHE - Shell fish, NS - Shrimp, TO - Tomato

A database trigger rejects item rows that contain a code not present in the `allergens` table, so typos can't make a dish look safe.

## 3. Build steps (in order)

### Database

1. Created the database `gaucho_allergens` and the tables `allergens` and `items` in PostgreSQL.
2. Added a GIN index on `items.contain` for fast overlap searches.
3. Wrote the trigger function `check_contain_codes()` to validate allergen codes.
4. Loaded the 25 allergen codes.
5. Imported all menu items from the PDF with `contain = NULL` and sections: Churrasco, Antipasto, Salad Station, Charcuterie, Cheese, Sides & Snacks, Canapés, Bread & Accompaniments, Warm Food.
6. Marked clearly vegan items from the menu with `vege = TRUE`.

### Go backend

1. Set up the project: `go mod init`, installed the `pgx` driver, fixed the empty `check.go` build error.
2. Read `DATABASE_URL` and `ADMIN_PASSWORD` from environment variables (no secrets in code).
3. Wrote the API `GET /api/allergens` (list of buttons).
4. Wrote `GET /api/check?a=ND,gluten`. It accepts a code or a full name, and returns three groups by section: cannot serve, can serve and unknown.
5. Built the chef admin: list of items, edit form with checkboxes, save with `UPDATE`, protected by HTTP basic authentication.
6. Used `PORT` from the environment so the app runs on Render.

### Frontend

1. Home page with two role buttons: Waiter and Chef.
2. Waiter page with allergen buttons, a search box and the three result lists by section: red (cannot serve), amber (ask the kitchen) and green (can serve).
3. Chef pages built with Go templates.
4. Applied the restaurant's colors (dark green `#283C1C`, pale yellow `#F8ECA4`), the Oswald font, a shared `style.css`, and the cow cuts picture on the home page.

## 4. Deployment and tools

| Component | Service | Plan |
| --- | --- | --- |
| Source code | GitHub (private repo `gaucho-allergens`) | Free |
| Web application | Render web service | Free |
| Database | Neon PostgreSQL (Frankfurt) | Free |
| Database admin | pgAdmin 4 (local and Neon servers) | Free |

Steps done:

1. Pushed the code to GitHub, fixing the "repository not found" error.
2. Exported the local database with `pg_dump` and imported it into Neon with `psql`.
3. Connected Render to the GitHub repository, and set the build command (`go build -o app .`), the start command (`./app`) and the environment variables.
4. Connected pgAdmin 4 to Neon (SSL mode: Require).
5. Synchronized the allergen table from local to Neon inside a transaction, then cleaned up old codes (Oil, Chi, OI, PE, Mu) from items and sent the affected items back to "Not checked".
6. Pushed the design update to GitHub, and Render redeployed automatically.

## 5. Problems solved, risks and next steps

### Problems and fixes.

- `expected 'package', found 'EOF'`: deleted the empty `check.go`.
- `&` in a Windows `set` command: the value needed quotes.
- Neon login failed: the password had been reset, so pgAdmin and Render needed the new one.
- Pasted SQL had quotes from pgAdmin's copy, which caused syntax errors.
- Duplicate name `Chili` when syncing allergens: replaced the table in one transaction, then checked for orphan codes.

### Risks and limits

- The free Render service sleeps after 15 minutes without traffic and takes about a minute to wake.
- The Neon free plan has limited compute hours and no guaranteed backup, so run `pg_dump` regularly.
- Allergen data must be filled in and verified by the chef. Until then, items show "Ask the kitchen".
- The website must not replace direct confirmation with the kitchen for severe allergies.
- Passwords were shared in chat during development, so reset them and use a strong admin password.

### Next steps

- [ ]  Chef fills in and verifies allergens for all items
- [x]  Confirm the seafood, fish and shellfish tagging rule with the chef
- [ ]  Add `last_verified` dates and a warning for old entries
- [x]  Reset the Neon and admin passwords
- [ ]  Move to a paid, always-on plan before real service
- [ ]  Optional: custom domain, login form, scheduled backups
- [x]  Demo to the manager
