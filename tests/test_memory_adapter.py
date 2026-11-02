"""Compile Ada and exercise its public interface against real SQLite files."""
from pathlib import Path
import sqlite3
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MemoryAdapterTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.build = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.build.cleanup)
        cls.binary = Path(cls.build.name) / 'memory_adapter_check'
        subprocess.run([
            'gnatmake', '-q', '-gnat2022', '-gnata', '-gnatwa', '-gnatwe',
            '-I' + str(ROOT / 'src'), '-o', str(cls.binary),
            str(ROOT / 'tests' / 'memory_adapter_check.adb'),
            '-largs', '-l:libsqlite3.so.0',
        ], cwd=cls.build.name, check=True)

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name) / 'memory.sqlite'

    def run_ada(self, mode='seed', schema=None):
        result = subprocess.run([str(self.binary), str(self.path), mode,
                                 str(schema or ROOT / 'sql' / '001_memory.sql')],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def rows(self):
        with sqlite3.connect(self.path) as db:
            return db.execute('SELECT id FROM memory_event ORDER BY id').fetchall()

    def test_round_trip_authorization_and_erasure(self):
        self.run_ada()
        self.assertEqual(self.rows(), [('a',), ('a2',), ('a3',), ('b',), ('leap',)])
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute('PRAGMA user_version').fetchone(), (1,))
            self.assertEqual(db.execute('PRAGMA integrity_check').fetchone(), ('ok',))
            self.assertEqual(db.execute(
                'SELECT id FROM current_memory_event ORDER BY id').fetchall(),
                [('a3',), ('b',), ('leap',)])
        self.run_ada('erase')
        self.assertEqual(self.rows(), [('b',)])

    def test_failed_erasure_rolls_back_all_deleted_records(self):
        self.run_ada()
        with sqlite3.connect(self.path) as db:
            db.execute('''CREATE TRIGGER injected_failure BEFORE DELETE ON memory_event
                WHEN OLD.id = 'a' BEGIN SELECT RAISE(ABORT, 'test failure'); END''')
        self.run_ada('erase-fails')
        self.assertEqual(self.rows(), [('a',), ('a2',), ('a3',), ('b',), ('leap',)])
        with sqlite3.connect(self.path) as db:
            db.execute('DROP TRIGGER injected_failure')
        self.run_ada('erase')
        self.assertEqual(self.rows(), [('b',)])

    def test_unknown_database_is_not_modified(self):
        with sqlite3.connect(self.path) as db:
            db.execute('CREATE TABLE unrelated(value TEXT)')
            db.execute("INSERT INTO unrelated VALUES ('keep')")
        self.run_ada('reject-open')
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute('SELECT * FROM unrelated').fetchall(), [('keep',)])
            self.assertEqual(db.execute('PRAGMA user_version').fetchone(), (0,))

    def test_competing_writer_fails_without_partial_insert(self):
        self.run_ada()
        with sqlite3.connect(self.path) as db:
            db.execute('BEGIN IMMEDIATE')
            self.run_ada('append-fails')
            db.rollback()
        self.assertEqual(self.rows(), [('a',), ('a2',), ('a3',), ('b',), ('leap',)])
        self.run_ada('erase')
        self.assertEqual(self.rows(), [('b',)])

    def test_future_schema_is_not_downgraded(self):
        with sqlite3.connect(self.path) as db:
            db.execute('PRAGMA user_version=2')
        self.run_ada('reject-open')
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute('PRAGMA user_version').fetchone(), (2,))

    def test_failed_schema_creation_rolls_back(self):
        schema = Path(self.directory.name) / 'broken.sql'
        schema.write_text('BEGIN IMMEDIATE; CREATE TABLE partial(id); INVALID SQL; COMMIT;')
        self.run_ada('reject-open', schema)
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute(
                "SELECT name FROM sqlite_master WHERE type='table'").fetchall(), [])


if __name__ == '__main__':
    unittest.main()
