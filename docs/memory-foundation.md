# Memory foundation — Ada SQLite adapter

Status: local implementation, compiled and tested with GNAT 13.3 on Linux.
Twenty-five test cases pass: seven schema checks, six Ada storage integration
scenarios, and twelve retrieval scenarios.

This implements Ada memory interfaces, an initial SQLite schema, and a working
SQLite adapter. It does not yet implement model selection, an AI
provider, a scheduler, or learning. No network requests or paid services are used
by this slice. The existing demonstration program remains separate.

## Files and checks

- `src/elephant_memory.ads`: proposed abstract storage interface.
- `src/elephant_memory-sqlite.ads` and `.adb`: owner-bound SQLite storage.
- `sql/001_memory.sql`: initial schema for a new SQLite database.
- `tests/test_memory_schema.py`: real SQLite persistence and integrity checks.
- `tests/memory_adapter_check.adb`: exercises the public Ada interface.
- `tests/test_memory_adapter.py`: compiles Ada with assertions and warnings treated
  as errors, then checks persisted data independently through Python's SQLite API.
- `tests/memory_retrieval_check.adb` and `tests/test_memory_retrieval.py`: compile
  and exercise listing/search through Ada, using independently seeded fixtures.

Run from the repository root:

```sh
python -B -m unittest discover -s tests -v
```

The Python here is test tooling, not a replacement for the Ada core.
Requires GNAT supporting Ada 2022, Python 3, and Linux `libsqlite3.so.0`.
The test runner builds and links in a temporary directory. No project build file
is required; the existing `elephant.gpr` remains a placeholder.

GitHub Actions runs the same test command on Ubuntu 24.04 for pushes, pull
requests, and manual workflow runs. `.github/workflows/ada-tests.yml` installs
GNAT, Python, and SQLite, then compiles Ada and runs all tests. The workflow has
read-only repository access and a ten-minute job limit. Its result appears under
the repository's Actions tab and on the associated commit or pull request.

## Using the adapter

Create an `Elephant_Memory.SQLite.SQLite_Store`, then call `Open` with the database
path and trusted owner identity. The default schema file is `sql/001_memory.sql`,
relative to the working directory; pass an absolute schema path when needed.
Only an empty version-zero database is initialized. Unknown nonempty databases
and schema versions other than 1 are rejected without migration.

`Append` stores one complete event atomically. `Read_Event` requires an ID and
matching requester. `Erase_Owner` removes the bound owner's entire event history
in one transaction. `Close` releases the connection; leaving scope also closes
it automatically. A rejected attempt to reopen an active store preserves the
original connection. Use a store from one Ada task at a time. Independent stores
can share a database; SQLite write conflicts time out after two seconds and
raise `Elephant_Memory.Storage_Error` without partially saving an event.

Catch `Elephant_Memory.Storage_Error` by its qualified name to distinguish it
from Ada's predefined `Standard.Storage_Error`. Invalid events, denied access,
and absent records have separate exceptions in `Elephant_Memory`.

## Listing and search

`List_Events (Target, Requester)` retrieves current records without knowing IDs.
`Search_Events (Target, Requester, Query)` searches only their content for a literal
substring. Both enforce the connection owner and return an `Event_Page` with
`Items` and `Has_More`. Each `Memory_Hit` contains the full event in `Item` and
an `Is_Current` flag. Source references, source kind, and evidence status remain
exactly as recorded; retrieval does not verify or rewrite them.

By default, only records with no correcting child are included. Set
`Include_History => True` to include superseded records. `Is_Current = False`
labels superseded history; a nonempty `Item.Supersedes_ID` identifies a correction
and links to its predecessor. Both leaves of a branching correction are returned
without declaring a winner. An original with no corrections is also current.

Results are ordered by `Recorded_UTC` descending, then ID in binary ascending
order to break timestamp ties. Pages default to 50 records; `Page_Size` restricts
`Limit` to 1–100. `Offset` skips matching records. `Has_More` is based on one extra
matching row rather than an expensive total count. A page is one SQLite statement
snapshot. Offset pagination across several calls can shift if writes occur
between calls; it does not promise a consistent multi-page snapshot.

Search folds ASCII case only. Non-ASCII bytes match exactly: `café` matches itself,
but `CAFÉ` does not match `café`. `%`, `_`, quotes, and SQL-looking text are literal
characters, not query syntax. Empty or ASCII-whitespace-only searches, embedded
NUL, and queries over 4,096 bytes raise `Invalid_Query`; leading/trailing spaces
in a nonblank query are retained. No matches return an empty page, not `Not_Found`.

This is a bounded literal-search API, not semantic recall or a conversation UI.
It uses the existing version-one schema and owner index; content matching scans
the owner's records. No search index, ranking model, or schema migration is added.

## Contract

Event IDs and original contents are immutable. A correction appends an event
referencing an existing event of the same owner. Several corrections may refer
to one original; the current-event view returns all leaves rather than choosing
one as truth. Application code must disclose disagreement and handle its resolution.

Sources and evidence status are separate. Model outputs default to unverified.
Verification requires a later event with evidence provenance, under application
policy; a database cannot decide whether a claim is true.

Ada enumeration values map to the SQL tokens with the same spelling in lower case.
An empty Ada supersedes ID maps to SQL NULL. IDs are supplied by the caller; an
adapter must generate collision-resistant IDs and report conflicts rather than
replace originals. SQL timestamps have UTC shape and SQLite date recognition
checks; the adapter additionally validates calendar dates and clock fields.
Recorded years use `Ada.Calendar.Year_Number`; leap seconds are not accepted.
Text fields preserve UTF-8 bytes, including quotes and long contents. Embedded
NUL characters are rejected before passing text into SQLite.

## Storage and access boundaries

The adapter enables and verifies foreign keys on every connection and uses
parameterized plain INSERT statements. The schema initializes in a transaction;
an initialization failure closes the connection and rolls back unfinished work.
The schema file is trusted application code, never an untrusted user upload.

The calling application must authenticate users and supply the trusted owner at
Open. The adapter enforces that identity for reads, writes, and erasure; caller
supplied event owners or requester strings cannot switch an active connection's
owner. It is not a login system or encryption boundary. Any process with direct
database write access can alter the schema and bypass application checks.

Deletion is intentionally available for authorized erasure. To erase an owner,
the adapter deletes descendant corrections before their originals in a single
transaction. An error rolls back the entire erasure. The calling application
must apply the agreed policy to backups, exports, and SQLite residual data.
This implementation does not provide secure deletion or a retention policy.

## Verification

Fresh integration tests cover exact field round trips, Unicode and quoted text,
20,000-byte content, valid leap dates and invalid calendar/clock values, duplicate
IDs, missing and cross-owner correction references, owner isolation, closed and
already-open connections, preservation after reopening, multi-generation erasure,
rollback after an injected mid-erasure failure, competing writers, unknown/future
schemas, and failed initialization. Existing schema tests also verify branching
corrections and protection against updates and INSERT OR REPLACE.

Retrieval tests cover owner isolation, historical-match suppression, explicit
history and correction labels, branching corrections, preserved provenance,
ASCII/Unicode matching, literal wildcards/quotes, SQL injection attempts,
content-only matching, tied timestamps, page/query boundaries, missing records,
closed connections, invalid queries, and read-only behavior.

The adapter uses SQLite's documented C interface, including parameter binding
with copied text and statement/connection cleanup:
https://sqlite.org/c3ref/bind_blob.html and https://sqlite.org/c3ref/close.html.

Not yet implemented: user login, semantic recall, ID generation, backup
management, provider adapters, model selection, background scheduling, or a new
interactive application. The earlier text-file demonstration remains separate.
