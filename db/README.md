# Database Layout

- `migrations/`: ordered schema changes applied once and tracked in `schema_migrations`
- `seeds/`: idempotent data inserts that can be reapplied safely

Add new migrations with a sortable prefix such as `0002_add_projects_slug.sql`.
