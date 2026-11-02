-- Initial schema for a NEW database only. Apply once, in a transaction.
-- Every connection must enable foreign_keys before beginning a transaction.
PRAGMA foreign_keys = ON;
BEGIN IMMEDIATE;

CREATE TABLE memory_event (
    id TEXT PRIMARY KEY NOT NULL CHECK (length(trim(id)) > 0),
    record_kind TEXT NOT NULL CHECK (length(trim(record_kind)) > 0),
    content TEXT NOT NULL CHECK (length(trim(content)) > 0),
    source_kind TEXT NOT NULL CHECK (source_kind IN (
        'human_statement', 'external_source', 'hypothesis', 'model_output',
        'verified_outcome', 'tool_output')),
    source_ref TEXT NOT NULL CHECK (length(trim(source_ref)) > 0),
    recorded_utc TEXT NOT NULL CHECK (
        length(recorded_utc) = 20 AND
        recorded_utc GLOB '????-??-??T??:??:??Z' AND
        julianday(recorded_utc) IS NOT NULL),
    evidence_status TEXT NOT NULL DEFAULT 'unverified'
        CHECK (evidence_status IN ('unverified', 'supported', 'disputed', 'verified')),
    owner_id TEXT NOT NULL CHECK (length(trim(owner_id)) > 0),
    supersedes_id TEXT REFERENCES memory_event(id) ON DELETE RESTRICT,
    CHECK (supersedes_id IS NULL OR supersedes_id <> id)
);

CREATE INDEX memory_event_owner ON memory_event(owner_id, recorded_utc, id);
CREATE INDEX memory_event_supersedes ON memory_event(supersedes_id);

CREATE TRIGGER memory_event_no_update BEFORE UPDATE ON memory_event
BEGIN
    SELECT RAISE(ABORT, 'append a correction instead of updating history');
END;

-- Reject an ID collision even for INSERT OR REPLACE, which could otherwise
-- delete an original silently. Each write must be a plain INSERT as well.
CREATE TRIGGER memory_event_no_replace BEFORE INSERT ON memory_event
WHEN EXISTS (SELECT 1 FROM memory_event WHERE id = NEW.id)
BEGIN
    SELECT RAISE(ABORT, 'event ID already exists');
END;

CREATE TRIGGER memory_event_correction_owner BEFORE INSERT ON memory_event
WHEN NEW.supersedes_id IS NOT NULL
BEGIN
    SELECT CASE WHEN NOT EXISTS (
        SELECT 1 FROM memory_event
        WHERE id = NEW.supersedes_id AND owner_id = NEW.owner_id
    ) THEN RAISE(ABORT, 'correction must reference existing history of same owner') END;
END;

-- Branching corrections remain visible; no automatic truth selection.
CREATE VIEW current_memory_event AS
SELECT original.* FROM memory_event AS original
WHERE NOT EXISTS (
    SELECT 1 FROM memory_event AS correction
    WHERE correction.supersedes_id = original.id
);

PRAGMA user_version = 1;
COMMIT;
