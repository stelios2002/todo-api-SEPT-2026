# Todo API

RESTful API σε Ruby on Rails 8 με JWT authentication. Κάθε χρήστης έχει πρόσβαση
αποκλειστικά στα δικά του todos.

## Τεχνολογίες

- Ruby on Rails 8.1 (API-only mode)
- SQLite3
- JWT (jwt gem) για stateless authentication
- bcrypt (`has_secure_password`) για password hashing

## Εγκατάσταση

```bash
git clone <repo-url>
cd todo_api
bundle install
rails db:setup    # δημιουργία βάσης + seeds
rails server
```

Ο server τρέχει στο `http://localhost:3000`.

Demo χρήστες (από τα seeds):

| Email | Password |
|---|---|
| maria@example.com | secret123 |
| giannis@example.com | secret456 |

## Μοντέλο δεδομένων

```
User  1 ──── n  Todo  1 ──── n  Item
```

- `User`: name, email (unique), password_digest
- `Todo`: title, description, completed, user_id
- `Item`: content, completed, position, todo_id

Διαγραφή χρήστη διαγράφει τα todos του, και διαγραφή todo διαγράφει τα items του
(`dependent: :destroy`).

## Authentication

Το `POST /signup` και το `POST /login` επιστρέφουν JWT token με διάρκεια 24 ωρών.
Όλα τα προστατευμένα endpoints απαιτούν header:

```
Authorization: Bearer <token>
```

Ο server δεν κρατάει sessions. Το `DELETE /logout` επιστρέφει μήνυμα επιβεβαίωσης
και ο client οφείλει να διαγράψει το token του.

## Endpoints

| Method | Path | Auth | Περιγραφή |
|---|---|:--:|---|
| POST | `/signup` | – | Εγγραφή, επιστρέφει token |
| POST | `/login` | – | Σύνδεση, επιστρέφει token |
| DELETE | `/logout` | – | Μήνυμα αποσύνδεσης |
| GET | `/me` | ✔ | Στοιχεία συνδεδεμένου χρήστη |
| GET | `/todos` | ✔ | Λίστα με φίλτρα και σελιδοποίηση |
| POST | `/todos` | ✔ | Δημιουργία |
| GET | `/todos/:id` | ✔ | Ένα todo |
| PATCH | `/todos/:id` | ✔ | Ενημέρωση |
| DELETE | `/todos/:id` | ✔ | Διαγραφή |

### Query parameters στο `GET /todos`

| Param | Τιμές | Default | Περιγραφή |
|---|---|---|---|
| `completed` | `true` / `false` | – | Φίλτρο κατάστασης |
| `q` | κείμενο | – | Αναζήτηση σε title και description (case-insensitive) |
| `sort` | `recent` / `oldest` | `recent` | Ταξινόμηση κατά created_at |
| `page` | ακέραιος ≥ 1 | 1 | Σελίδα |
| `per_page` | 1–100 | 10 | Αποτελέσματα ανά σελίδα |

Παράδειγμα: `GET /todos?completed=false&q=rails&sort=oldest&page=1&per_page=5`

## Παραδείγματα

Εγγραφή:

```bash
curl -X POST http://localhost:3000/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Maria","email":"maria@example.com","password":"secret123"}'
```

Δημιουργία todo:

```bash
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"title":"Buy milk","description":"Full fat"}'
```

Λίστα με φίλτρα:

```bash
curl "http://localhost:3000/todos?completed=false&q=milk" \
  -H "Authorization: Bearer <TOKEN>"
```

Απάντηση:

```json
{
  "meta": { "total_count": 1, "page": 1, "per_page": 10, "total_pages": 1 },
  "todos": [
    {
      "id": 1,
      "title": "Buy milk",
      "description": "Full fat",
      "completed": false,
      "items_count": 0,
      "created_at": "2026-09-01T10:00:00.000Z",
      "updated_at": "2026-09-01T10:00:00.000Z"
    }
  ]
}
```

## HTTP status codes

| Code | Πότε |
|---|---|
| 200 OK | Επιτυχής ανάγνωση, ενημέρωση, διαγραφή |
| 201 Created | Επιτυχής δημιουργία (signup, POST /todos) |
| 401 Unauthorized | Λείπει, είναι άκυρο ή έχει λήξει το token / λάθος credentials |
| 404 Not Found | Το resource δεν υπάρχει ή δεν ανήκει στον χρήστη |
| 422 Unprocessable Entity | Απέτυχαν τα validations |

## Ασφάλεια

- Τα passwords αποθηκεύονται ως bcrypt hash, ποτέ σε plain text.
- Κάθε query ξεκινά από `current_user.todos`, οπότε είναι αδύνατο να διαβαστεί ή
  να τροποποιηθεί ξένο resource. Απόπειρα πρόσβασης σε todo άλλου χρήστη
  επιστρέφει **404** και όχι 403, ώστε να μην αποκαλύπτεται η ύπαρξή του.
- Η αναζήτηση χρησιμοποιεί parameterized queries (προστασία από SQL injection).
- Τα strong parameters επιτρέπουν μόνο συγκεκριμένα πεδία, οπότε ο client δεν
  μπορεί να στείλει `user_id` και να αλλάξει ιδιοκτησία.