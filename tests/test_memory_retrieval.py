"""Independent fixtures exercise owner-scoped retrieval through compiled Ada."""
from pathlib import Path
import sqlite3
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class MemoryRetrievalTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.build = tempfile.TemporaryDirectory()
        cls.addClassCleanup(cls.build.cleanup)
        cls.binary = Path(cls.build.name) / 'memory_retrieval_check'
        subprocess.run([
            'gnatmake', '-q', '-gnat2022', '-gnata', '-gnatwa', '-gnatwe',
            '-I' + str(ROOT / 'src'), '-o', str(cls.binary),
            str(ROOT / 'tests' / 'memory_retrieval_check.adb'),
            '-largs', '-l:libsqlite3.so.0',
        ], cwd=cls.build.name, check=True)

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name) / 'memory.sqlite'
        with sqlite3.connect(self.path) as db:
            db.executescript((ROOT / 'sql' / '001_memory.sql').read_text())
            for identity, content, owner, previous, source, evidence, day in [
                ('original', 'Sirius is my old favourite', 'alice', None,
                 'model_output', 'unverified', '01'),
                ('left', 'Vega is my favourite star', 'alice', 'original',
                 'human_statement', 'supported', '02'),
                ('right', 'Altair is my favourite star', 'alice', 'original',
                 'hypothesis', 'disputed', '02'),
                ('literal', "100%_ literal 'quote' café", 'alice', None,
                 'external_source', 'verified', '03'),
                ('private', 'Sirius and Vega are private', 'bob', None,
                 'human_statement', 'unverified', '04'),
            ]:
                db.execute('''INSERT INTO memory_event
                    (id,record_kind,content,source_kind,source_ref,recorded_utc,
                     evidence_status,owner_id,supersedes_id)
                    VALUES (?, 'preference', ?, ?, 'fixture:source', ?, ?, ?, ?)''',
                    (identity, content, source, f'2026-11-{day}T12:00:00Z',
                     evidence, owner, previous))

    def retrieve(self, mode='list', query='', history=False, limit=50, offset=0,
                 owner='alice', requester='alice'):
        result = subprocess.run([
            str(self.binary), str(self.path), owner, requester, mode, query,
            str(history), str(limit), str(offset),
        ], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        lines = result.stdout.splitlines()
        if lines[0].startswith('ERROR='):
            return lines[0]
        self.assertTrue(lines[-1].startswith('MORE='), result.stdout)
        return [line.split('\t') for line in lines[:-1]], lines[-1] == 'MORE=TRUE'

    def ids(self, **options):
        rows, more = self.retrieve(**options)
        return [row[0] for row in rows], more

    def test_current_listing_preserves_both_correction_branches(self):
        self.assertEqual(self.ids(), (['literal', 'left', 'right'], False))

    def test_history_labels_originals_and_corrections_and_preserves_provenance(self):
        rows, more = self.retrieve(history=True)
        self.assertFalse(more)
        by_id = {row[0]: row[1:] for row in rows}
        self.assertEqual(by_id['original'], [
            'FALSE', '', 'MODEL_OUTPUT', 'UNVERIFIED', 'Sirius is my old favourite',
            'fixture:source', 'preference', '2026-11-01T12:00:00Z', 'alice'])
        self.assertEqual(by_id['right'][:4], ['TRUE', 'original', 'HYPOTHESIS', 'DISPUTED'])
        self.assertEqual(by_id['literal'][2:4], ['EXTERNAL_SOURCE', 'VERIFIED'])

    def test_historical_match_requires_explicit_history(self):
        self.assertEqual(self.ids(mode='search', query='Sirius'), ([], False))
        self.assertEqual(self.ids(mode='search', query='sIrIuS', history=True),
                         (['original'], False))

    def test_search_is_literal_and_cannot_inject_sql(self):
        for query in ['%_', "'quote'", 'café']:
            with self.subTest(query=query):
                self.assertEqual(self.ids(mode='search', query=query), (['literal'], False))
        self.assertEqual(self.ids(mode='search', query="' OR 1=1 --"), ([], False))
        self.assertEqual(self.ids(), (['literal', 'left', 'right'], False))

    def test_ascii_case_insensitive_search_and_unicode_policy(self):
        self.assertEqual(self.ids(mode='search', query='FAVOURITE'), (['left', 'right'], False))
        self.assertEqual(self.ids(mode='search', query='CAFÉ'), ([], False))

    def test_searches_only_content(self):
        for query in ['fixture:source', 'preference', 'alice']:
            self.assertEqual(self.ids(mode='search', query=query), ([], False))

    def test_pagination_has_stable_order_and_accurate_more_flag(self):
        self.assertEqual(self.ids(limit=1), (['literal'], True))
        self.assertEqual(self.ids(limit=1, offset=1), (['left'], True))
        self.assertEqual(self.ids(limit=1, offset=2), (['right'], False))
        self.assertEqual(self.ids(limit=1, offset=3), ([], False))
        self.assertEqual(self.ids(mode='search', query='star', limit=1), (['left'], True))
        self.assertEqual(self.ids(mode='search', query='star', limit=1, offset=1),
                         (['right'], False))

    def test_other_owners_are_isolated_for_both_search_and_listing(self):
        self.assertEqual(self.ids(owner='bob', requester='bob'), (['private'], False))
        self.assertEqual(self.ids(mode='search', query='private', history=True), ([], False))
        for mode in ['list', 'search']:
            self.assertEqual(self.retrieve(mode=mode, query='star', requester='bob'),
                             'ERROR=Access_Denied')

    def test_maximum_page_and_query_boundaries(self):
        with sqlite3.connect(self.path) as db:
            for index in range(102):
                db.execute('''INSERT INTO memory_event
                    (id,record_kind,content,source_kind,source_ref,recorded_utc,owner_id)
                    VALUES (?, 'note', 'bulk memory', 'human_statement',
                            'fixture:bulk', '2026-11-05T00:00:00Z', 'alice')''',
                           (f'bulk-{index:03}',))
        self.assertEqual(self.ids(limit=100), ([f'bulk-{i:03}' for i in range(100)], True))
        self.assertEqual(self.ids(limit=100, offset=100),
                         (['bulk-100', 'bulk-101', 'literal', 'left', 'right'], False))
        self.assertEqual(self.ids(mode='search', query='x' * 4096), ([], False))
        self.assertEqual(self.ids(offset=2147483647), ([], False))

    def test_invalid_searches_are_rejected(self):
        for query in ['', '  ', '\t\r\n', 'x' * 4097]:
            with self.subTest(length=len(query)):
                self.assertEqual(self.retrieve(mode='search', query=query), 'ERROR=Invalid_Query')
        self.assertEqual(self.retrieve(mode='nul'), 'ERROR=Invalid_Query')

    def test_empty_owner_and_closed_connection_results(self):
        self.assertEqual(self.ids(owner='nobody', requester='nobody'), ([], False))
        self.assertEqual(self.retrieve(mode='closed'), 'ERROR=Storage_Error')

    def test_retrieval_does_not_change_events_or_promote_evidence(self):
        def snapshot():
            with sqlite3.connect(self.path) as db:
                return db.execute('SELECT * FROM memory_event ORDER BY id').fetchall()
        before = snapshot()
        self.retrieve(history=True)
        self.retrieve(mode='search', query='star', history=True)
        self.assertEqual(snapshot(), before)


if __name__ == '__main__':
    unittest.main()
