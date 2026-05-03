CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS schema_migrations (
    filename   TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS url_types (
    id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name  TEXT NOT NULL UNIQUE,
    icon  TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS languages (
    id    SERIAL PRIMARY KEY,
    name  TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS markdown_files (
    id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS urls (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    url         TEXT NOT NULL,
    url_type_id UUID NOT NULL REFERENCES url_types(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS journal_entries (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    create_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    title            TEXT NOT NULL,
    summary          TEXT NOT NULL,
    markdown_file_id UUID NOT NULL REFERENCES markdown_files(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS projects (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    create_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    title            TEXT NOT NULL,
    summary          TEXT NOT NULL,
    markdown_file_id UUID NOT NULL REFERENCES markdown_files(id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS experiences (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    start_date  DATE NOT NULL,
    end_date    DATE,
    title       TEXT NOT NULL,
    summary     TEXT NOT NULL,
    description TEXT NOT NULL,
    CONSTRAINT chk_experience_dates CHECK (end_date IS NULL OR end_date > start_date)
);

CREATE TABLE IF NOT EXISTS comments (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    parent_id        UUID REFERENCES comments(id) ON DELETE CASCADE,
    guest_name       TEXT NOT NULL,
    body             TEXT NOT NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS comment_likes (
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id UUID NOT NULL REFERENCES comments(id) ON DELETE CASCADE,
    guest_name TEXT NOT NULL,
    reaction   TEXT NOT NULL DEFAULT 'heart',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_comment_like UNIQUE (comment_id, guest_name)
);

CREATE TABLE IF NOT EXISTS project_urls (
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    url_id     UUID NOT NULL REFERENCES urls(id) ON DELETE CASCADE,
    PRIMARY KEY (project_id, url_id)
);

CREATE TABLE IF NOT EXISTS project_languages (
    project_id  UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    language_id INT NOT NULL REFERENCES languages(id) ON DELETE RESTRICT,
    PRIMARY KEY (project_id, language_id)
);

CREATE TABLE IF NOT EXISTS experience_languages (
    experience_id UUID NOT NULL REFERENCES experiences(id) ON DELETE CASCADE,
    language_id   INT NOT NULL REFERENCES languages(id) ON DELETE RESTRICT,
    PRIMARY KEY (experience_id, language_id)
);

CREATE INDEX IF NOT EXISTS idx_journal_entries_create_date
    ON journal_entries(create_date DESC);

CREATE INDEX IF NOT EXISTS idx_projects_create_date
    ON projects(create_date DESC);

CREATE INDEX IF NOT EXISTS idx_experiences_start_date
    ON experiences(start_date DESC);

CREATE INDEX IF NOT EXISTS idx_comments_journal_entry_created_at
    ON comments(journal_entry_id, created_at);

CREATE INDEX IF NOT EXISTS idx_comments_parent_id
    ON comments(parent_id) WHERE parent_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_urls_url_type_id
    ON urls(url_type_id);
