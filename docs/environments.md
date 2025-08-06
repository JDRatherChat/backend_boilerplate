# Environment Choices

This project supports two database options:

### SQLite (default)

- Simple for local development.
- Zero setup required.

### Postgres (recommended for staging/prod)

- Production-ready.
- Docker Compose configuration included.
- Supports advanced features (JSON fields, full-text search).

Switch by setting `DATABASE_URL` in your `.env` file.

## Example

```ini
# dev.env
DEBUG = True
DATABASE_URL = sqlite:///db.sqlite3

# prod.env
DEBUG = False
DATABASE_URL = postgres://<username>:<password>@<host>:5432/<dbname>
````
