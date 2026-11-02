"""Storage contract checks using a real temporary SQLite file; no paid services."""
from pathlib import Path
import sqlite3
import tempfile
import unittest

SCHEMA = Path(__file__).resolve().parents[1] / 'sql' / '001_memory.sql'


class MemorySchemaTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.path = Path(self.directory.name) / 'memory.sqlite'
        self.db = sqlite3.connect(self.path)
        self.db.executescript(SCHEMA.read_text())

    def tearDown(self):
        self.db.close()
        self.directory.cleanup()

    def append(self, identity, content='Original words', owner='owner-a',
               supersedes=None, source='human_statement'):
        self.db.execute('''INSERT INTO memory_event
            (id, record_kind, content, source_kind, source_ref, recorded_utc,
             owner_id, supersedes_id) VALUES (?, 'note', ?, ?, 'message:1',
             '2026-11-02T23:00:00Z', ?, ?)''',
            (identity, content, source, owner, supersedes))

    def test_corrections_preserve_original_after_reopen(self):
        self.append('a')
        self.append('b', content='Corrected words', supersedes='a')
        self.db.commit()
        self.db.close()
        self.db = sqlite3.connect(self.path)
        self.assertEqual(self.db.execute(
            'SELECT content FROM memory_event WHERE id="a"').fetchone()[0],
            'Original words')
        self.assertEqual(self.db.execute(
            'SELECT id FROM current_memory_event').fetchall(), [('b',)])

    def test_updates_and_replace_cannot_destroy_original(self):
        self.append('a')
        for statement in [
            "UPDATE memory_event SET content='changed' WHERE id='a'",
            "INSERT OR REPLACE INTO memory_event SELECT * FROM memory_event",
        ]:
            with self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(statement)
        self.assertEqual(self.db.execute(
            'SELECT content FROM memory_event').fetchall(), [('Original words',)])

    def test_missing_or_cross_owner_corrections_rejected(self):
        self.append('a')
        for previous, owner in [('missing', 'owner-a'), ('a', 'owner-b')]:
            with self.assertRaises(sqlite3.IntegrityError):
                self.append('b', supersedes=previous, owner=owner)

    def test_model_output_defaults_to_unverified(self):
        self.append('a', source='model_output')
        self.assertEqual(self.db.execute(
            'SELECT evidence_status FROM memory_event').fetchone()[0], 'unverified')

    def test_branching_corrections_are_both_visible(self):
        self.append('a')
        self.append('b', supersedes='a')
        self.append('c', supersedes='a')
        self.assertEqual(self.db.execute(
            'SELECT id FROM current_memory_event ORDER BY id').fetchall(),
            [('b',), ('c',)])

    def test_erasure_removes_history_without_other_owner(self):
        self.append('a')
        self.append('b', supersedes='a')
        self.append('c', owner='owner-b')
        # Adapter deletes descendants before ancestors in one transaction.
        self.db.execute("DELETE FROM memory_event WHERE id='b'")
        self.db.execute("DELETE FROM memory_event WHERE id='a'")
        self.assertEqual(self.db.execute(
            'SELECT id FROM memory_event').fetchall(), [('c',)])

    def test_empty_provenance_and_invalid_timestamp_rejected(self):
        self.append('a')
        for column, value in [('source_ref', ''), ('recorded_utc', 'yesterday'),
                              ('owner_id', ''), ('source_kind', 'unknown')]:
            with self.assertRaises(sqlite3.IntegrityError):
                self.db.execute(f'''INSERT INTO memory_event
                    SELECT 'b', record_kind, content,
                    {"?" if column == "source_kind" else "source_kind"},
                    {"?" if column == "source_ref" else "source_ref"},
                    {"?" if column == "recorded_utc" else "recorded_utc"},
                    evidence_status,
                    {"?" if column == "owner_id" else "owner_id"}, NULL
                    FROM memory_event WHERE id='a' ''', (value,))


if __name__ == '__main__':
    unittest.main()
