INSERT INTO url_types (id, name, icon)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'github', 'mdi:github'),
    ('22222222-2222-2222-2222-222222222222', 'website', 'mdi:web'),
    ('33333333-3333-3333-3333-333333333333', 'docs', 'mdi:file-document-outline'),
    ('44444444-4444-4444-4444-444444444444', 'demo', 'mdi:monitor-dashboard'),
    ('55555555-5555-5555-5555-555555555555', 'article', 'mdi:newspaper-variant-outline')
ON CONFLICT (id) DO UPDATE
SET
    name = EXCLUDED.name,
    icon = EXCLUDED.icon;

INSERT INTO languages (id, name)
VALUES
    (1, 'C++'),
    (2, 'PostgreSQL'),
    (3, 'Docker'),
    (4, 'TypeScript'),
    (5, 'Go'),
    (6, 'Python'),
    (7, 'Redis'),
    (8, 'Kubernetes'),
    (9, 'React'),
    (10, 'gRPC')
ON CONFLICT (id) DO UPDATE
SET name = EXCLUDED.name;

SELECT setval(
    pg_get_serial_sequence('languages', 'id'),
    GREATEST((SELECT COALESCE(MAX(id), 1) FROM languages), 1),
    true
);

WITH journal_seed AS (
    SELECT
        gs AS idx,
        ('10000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS markdown_id,
        ('20000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS entry_id,
        (ARRAY[
            'API Boundary Mapping',
            'Query Plan Review',
            'Session Management Cleanup',
            'Release Pipeline Hardening',
            'Search Ranking Tuning',
            'Cache Consistency Notes',
            'Observability Backlog',
            'Accessibility Pass',
            'Schema Evolution Draft',
            'Incident Follow-up'
        ])[((gs - 1) % 10) + 1] AS topic,
        (ARRAY[
            'service contracts',
            'index coverage',
            'cookie rotation',
            'deployment rollback',
            'result freshness',
            'cache invalidation',
            'signal quality',
            'keyboard support',
            'migration order',
            'postmortem actions'
        ])[((gs - 1) % 10) + 1] AS focus
    FROM generate_series(1, 50) AS gs
)
INSERT INTO markdown_files (id, content)
SELECT
    markdown_id,
    '# Weekly Note ' || lpad(idx::text, 2, '0') || ': ' || topic ||
    E'\n\n' ||
    'This entry records the current state of ' || focus || ' and identifies the next concrete change.' ||
    E'\n\n## Summary\n' ||
    'The team reviewed edge cases, clarified ownership boundaries, and documented a smaller follow-up task list.' ||
    E'\n\n## Next Steps\n' ||
    '- Validate assumptions with production-like data.' ||
    E'\n- Trim unnecessary branching in the implementation.' ||
    E'\n- Keep the rollout observable and easy to reverse.'
FROM journal_seed
ON CONFLICT (id) DO UPDATE
SET content = EXCLUDED.content;

WITH journal_seed AS (
    SELECT
        gs AS idx,
        ('10000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS markdown_id,
        ('20000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS entry_id,
        (ARRAY[
            'API Boundary Mapping',
            'Query Plan Review',
            'Session Management Cleanup',
            'Release Pipeline Hardening',
            'Search Ranking Tuning',
            'Cache Consistency Notes',
            'Observability Backlog',
            'Accessibility Pass',
            'Schema Evolution Draft',
            'Incident Follow-up'
        ])[((gs - 1) % 10) + 1] AS topic
    FROM generate_series(1, 50) AS gs
)
INSERT INTO journal_entries (id, create_date, title, markdown_file_id)
SELECT
    entry_id,
    (DATE '2026-01-01' + ((idx - 1) * INTERVAL '1 day'))::date,
    'Journal Entry ' || lpad(idx::text, 2, '0') || ': ' || topic,
    markdown_id
FROM journal_seed
ON CONFLICT (id) DO UPDATE
SET
    create_date = EXCLUDED.create_date,
    title = EXCLUDED.title,
    markdown_file_id = EXCLUDED.markdown_file_id;

WITH project_seed AS (
    SELECT
        gs AS idx,
        ('30000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS markdown_id,
        ('40000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS project_id,
        (ARRAY[
            'Metrics Pipeline',
            'Admin Dashboard',
            'Identity Gateway',
            'Search Indexer',
            'Billing Portal',
            'Design System',
            'Docs Hub',
            'Queue Monitor',
            'Audit Timeline',
            'Incident Toolkit'
        ])[((gs - 1) % 10) + 1] AS project_name,
        (ARRAY[
            'ingest platform events and surface delivery lag',
            'give operators a compact control surface for routine tasks',
            'centralize token exchange and permission checks',
            'improve retrieval speed for large content collections',
            'make invoice review and retry workflows easier to trust',
            'standardize reusable UI primitives across internal tools',
            'publish product knowledge without deployment friction',
            'highlight queue health, retries, and dead-letter drift',
            'trace compliance-sensitive mutations over time',
            'reduce time-to-diagnosis during production incidents'
        ])[((gs - 1) % 10) + 1] AS goal
    FROM generate_series(1, 50) AS gs
)
INSERT INTO markdown_files (id, content)
SELECT
    markdown_id,
    '# Project ' || lpad(idx::text, 2, '0') || ': ' || project_name ||
    E'\n\n' ||
    'Goal: ' || goal || '.' ||
    E'\n\n## Scope\n' ||
    'The implementation covers the service boundary, storage model, and an operational feedback loop.' ||
    E'\n\n## Current Status\n' ||
    'The project is structured, testable, and ready for iterative delivery milestones.'
FROM project_seed
ON CONFLICT (id) DO UPDATE
SET content = EXCLUDED.content;

WITH project_seed AS (
    SELECT
        gs AS idx,
        ('30000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS markdown_id,
        ('40000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS project_id,
        (ARRAY[
            'Metrics Pipeline',
            'Admin Dashboard',
            'Identity Gateway',
            'Search Indexer',
            'Billing Portal',
            'Design System',
            'Docs Hub',
            'Queue Monitor',
            'Audit Timeline',
            'Incident Toolkit'
        ])[((gs - 1) % 10) + 1] AS project_name
    FROM generate_series(1, 50) AS gs
)
INSERT INTO projects (id, create_date, title, markdown_file_id)
SELECT
    project_id,
    (DATE '2025-06-01' + ((idx - 1) * INTERVAL '5 day'))::date,
    'Project ' || lpad(idx::text, 2, '0') || ': ' || project_name,
    markdown_id
FROM project_seed
ON CONFLICT (id) DO UPDATE
SET
    create_date = EXCLUDED.create_date,
    title = EXCLUDED.title,
    markdown_file_id = EXCLUDED.markdown_file_id;

WITH experience_seed AS (
    SELECT
        gs AS idx,
        ('50000000-0000-0000-0000-' || lpad(to_hex(gs), 12, '0'))::uuid AS experience_id,
        (ARRAY[
            'Platform Engineer',
            'Backend Engineer',
            'Systems Engineer',
            'Product Engineer',
            'Data Engineer',
            'Site Reliability Engineer',
            'Developer Experience Engineer',
            'Infrastructure Engineer',
            'Application Engineer',
            'Technical Lead'
        ])[((gs - 1) % 10) + 1] AS role_name,
        (ARRAY[
            'stabilized service contracts and deployment patterns',
            'reduced operational friction in database-heavy services',
            'simplified diagnostics for distributed request flows',
            'connected product feedback to implementation priorities',
            'improved data quality checks and delivery traceability',
            'tightened alerting around failure modes with customer impact',
            'shortened local setup time and test feedback loops',
            'made runtime infrastructure safer to change',
            'refined core workflows with incremental rollout gates',
            'balanced delivery speed against long-term maintainability'
        ])[((gs - 1) % 10) + 1] AS impact
    FROM generate_series(1, 50) AS gs
)
INSERT INTO experiences (id, start_date, end_date, title, description)
SELECT
    experience_id,
    (DATE '2018-01-01' + ((idx - 1) * INTERVAL '45 day'))::date,
    CASE
        WHEN idx % 8 = 0 THEN NULL
        ELSE (DATE '2018-01-01' + ((idx - 1) * INTERVAL '45 day') + INTERVAL '540 day')::date
    END,
    role_name || ' ' || lpad(idx::text, 2, '0'),
    'Focused on platform delivery, team coordination, and codebase simplification. This role specifically ' || impact || '.'
FROM experience_seed
ON CONFLICT (id) DO UPDATE
SET
    start_date = EXCLUDED.start_date,
    end_date = EXCLUDED.end_date,
    title = EXCLUDED.title,
    description = EXCLUDED.description;

WITH project_url_seed AS (
    SELECT
        project_idx,
        slot,
        ('60000000-0000-0000-0000-' || lpad(to_hex(((project_idx - 1) * 2) + slot), 12, '0'))::uuid AS url_id,
        ('40000000-0000-0000-0000-' || lpad(to_hex(project_idx), 12, '0'))::uuid AS project_id,
        CASE slot
            WHEN 1 THEN '11111111-1111-1111-1111-111111111111'::uuid
            ELSE '33333333-3333-3333-3333-333333333333'::uuid
        END AS url_type_id,
        CASE slot
            WHEN 1 THEN 'https://github.com/example/project-' || lpad(project_idx::text, 2, '0')
            ELSE 'https://docs.example.com/project-' || lpad(project_idx::text, 2, '0')
        END AS url_value
    FROM generate_series(1, 50) AS project_idx
    CROSS JOIN generate_series(1, 2) AS slot
)
INSERT INTO urls (id, url, url_type_id)
SELECT url_id, url_value, url_type_id
FROM project_url_seed
ON CONFLICT (id) DO UPDATE
SET
    url = EXCLUDED.url,
    url_type_id = EXCLUDED.url_type_id;

WITH project_url_seed AS (
    SELECT
        ('40000000-0000-0000-0000-' || lpad(to_hex(project_idx), 12, '0'))::uuid AS project_id,
        ('60000000-0000-0000-0000-' || lpad(to_hex(((project_idx - 1) * 2) + slot), 12, '0'))::uuid AS url_id
    FROM generate_series(1, 50) AS project_idx
    CROSS JOIN generate_series(1, 2) AS slot
)
INSERT INTO project_urls (project_id, url_id)
SELECT project_id, url_id
FROM project_url_seed
ON CONFLICT DO NOTHING;

WITH project_language_seed AS (
    SELECT
        ('40000000-0000-0000-0000-' || lpad(to_hex(project_idx), 12, '0'))::uuid AS project_id,
        ((project_idx - 1) % 10) + 1 AS language_id
    FROM generate_series(1, 50) AS project_idx

    UNION

    SELECT
        ('40000000-0000-0000-0000-' || lpad(to_hex(project_idx), 12, '0'))::uuid AS project_id,
        ((project_idx) % 10) + 1 AS language_id
    FROM generate_series(1, 50) AS project_idx

    UNION

    SELECT
        ('40000000-0000-0000-0000-' || lpad(to_hex(project_idx), 12, '0'))::uuid AS project_id,
        ((project_idx + 1) % 10) + 1 AS language_id
    FROM generate_series(1, 50) AS project_idx
)
INSERT INTO project_languages (project_id, language_id)
SELECT project_id, language_id
FROM project_language_seed
ON CONFLICT DO NOTHING;

WITH experience_language_seed AS (
    SELECT
        ('50000000-0000-0000-0000-' || lpad(to_hex(experience_idx), 12, '0'))::uuid AS experience_id,
        ((experience_idx - 1) % 10) + 1 AS language_id
    FROM generate_series(1, 50) AS experience_idx

    UNION

    SELECT
        ('50000000-0000-0000-0000-' || lpad(to_hex(experience_idx), 12, '0'))::uuid AS experience_id,
        ((experience_idx + 2) % 10) + 1 AS language_id
    FROM generate_series(1, 50) AS experience_idx
)
INSERT INTO experience_languages (experience_id, language_id)
SELECT experience_id, language_id
FROM experience_language_seed
ON CONFLICT DO NOTHING;

WITH comment_seed AS (
    SELECT
        journal_idx,
        comment_slot,
        ('70000000-0000-0000-0000-' || lpad(to_hex(((journal_idx - 1) * 2) + comment_slot), 12, '0'))::uuid AS comment_id,
        ('20000000-0000-0000-0000-' || lpad(to_hex(journal_idx), 12, '0'))::uuid AS journal_entry_id,
        CASE
            WHEN comment_slot = 1 THEN NULL
            ELSE ('70000000-0000-0000-0000-' || lpad(to_hex(((journal_idx - 1) * 2) + 1), 12, '0'))::uuid
        END AS parent_id,
        CASE ((journal_idx + comment_slot - 2) % 5) + 1
            WHEN 1 THEN 'alex'
            WHEN 2 THEN 'sam'
            WHEN 3 THEN 'riley'
            WHEN 4 THEN 'casey'
            ELSE 'jordan'
        END AS guest_name,
        CASE
            WHEN comment_slot = 1 THEN
                'This note makes the trade-offs clear and leaves a concrete next step for the next pass.'
            ELSE
                'Following up with a narrower question would help validate the rollout plan before implementation starts.'
        END AS body,
        (TIMESTAMPTZ '2026-01-01 09:00:00+00' + ((journal_idx - 1) * INTERVAL '1 day') + ((comment_slot - 1) * INTERVAL '20 minute')) AS created_at
    FROM generate_series(1, 50) AS journal_idx
    CROSS JOIN generate_series(1, 2) AS comment_slot
)
INSERT INTO comments (id, journal_entry_id, parent_id, guest_name, body, created_at)
SELECT comment_id, journal_entry_id, parent_id, guest_name, body, created_at
FROM comment_seed
ON CONFLICT (id) DO UPDATE
SET
    journal_entry_id = EXCLUDED.journal_entry_id,
    parent_id = EXCLUDED.parent_id,
    guest_name = EXCLUDED.guest_name,
    body = EXCLUDED.body,
    created_at = EXCLUDED.created_at;

WITH like_seed AS (
    SELECT
        journal_idx,
        ('80000000-0000-0000-0000-' || lpad(to_hex(journal_idx), 12, '0'))::uuid AS like_id,
        ('70000000-0000-0000-0000-' || lpad(to_hex(((journal_idx - 1) * 2) + 1), 12, '0'))::uuid AS comment_id,
        CASE (journal_idx % 5) + 1
            WHEN 1 THEN 'morgan'
            WHEN 2 THEN 'taylor'
            WHEN 3 THEN 'jamie'
            WHEN 4 THEN 'drew'
            ELSE 'quinn'
        END AS guest_name,
        (ARRAY['heart', 'insightful', 'support', 'celebrate', 'curious'])[(journal_idx % 5) + 1] AS reaction,
        (TIMESTAMPTZ '2026-01-01 10:00:00+00' + ((journal_idx - 1) * INTERVAL '1 day')) AS created_at
    FROM generate_series(1, 50) AS journal_idx
)
INSERT INTO comment_likes (id, comment_id, guest_name, reaction, created_at)
SELECT like_id, comment_id, guest_name, reaction, created_at
FROM like_seed
ON CONFLICT (id) DO UPDATE
SET
    comment_id = EXCLUDED.comment_id,
    guest_name = EXCLUDED.guest_name,
    reaction = EXCLUDED.reaction,
    created_at = EXCLUDED.created_at;
