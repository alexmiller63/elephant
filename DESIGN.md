# Elephant Design

> An elephant remembers what matters.

This document defines the first working implementation of Elephant.

The purpose of this version is not to implement the full architecture.

The purpose is to prove one complete idea:

**Elephant can take something worth remembering, store it durably, and retrieve it later.**

## Version 0.1

Elephant 0.1 will implement one small end-to-end memory loop.

It will be able to:

- accept a memory from the user

- assign the memory a stable identifier

- record its source

- record when it was created

- store it in a human-readable file

- list stored memories

- retrieve a memory later

- preserve the memory in a Git repository

That is enough for the first working Elephant.

## Repository Layout

The initial repository can remain very small.

    Elephant/

    |

    +-- README.md

    +-- VISION.md

    +-- PRINCIPLES.md

    +-- ARCHITECTURE.md

    +-- DATA-MODEL.md

    +-- ROADMAP.md

    +-- DESIGN.md

    +-- LICENSE

    |

    +-- elephant/

    |     +-- __init__.py

    |     +-- cli.py

    |     +-- memory.py

    |

    +-- memories/

    |

    +-- tests/

The exact structure may change as we learn from the implementation.

The important distinction is between:

- program code

- durable memories

- tests

- project documentation

## The First Memory Record

Elephant 0.1 will use a deliberately small record.

Each memory will contain:

    id

    type

    content

    source

    created

For example:

    id: 20260808-001

    type: fact

    source: human

    created: 2026-08-08T04:45:00Z

    Elephant is intended to preserve continuity

    between humans, AIs, and tools.

This is not the final Elephant data model.

It is the smallest useful implementation of the model described in DATA-MODEL.md.

## Storage Format

The first implementation will store each memory as a Markdown file.

For example:

    memories/20260808-001.md

A memory file might contain:

    # Memory 20260808-001

    Type: fact

    Source: human

    Created: 2026-08-08T04:45:00Z

    ## Content

    Elephant is intended to preserve continuity

    between humans, AIs, and tools.

Markdown is appropriate for version 0.1 because it is:

- human-readable

- easy to inspect

- easy to edit

- easy to version with Git

- independent of Elephant itself

If Elephant disappears, the memory remains understandable.

## Memory Identifiers

Every memory needs a stable identifier.

For version 0.1, Elephant may generate an identifier using the date and a sequence number.

For example:

    20260808-001

    20260808-002

    20260808-003

The implementation may later move to UUIDs or another identifier system.

The important requirement is that an identifier remains stable once assigned.

## Command-Line Interface

The first Elephant interface will be a command-line program.

A possible interface is:

    elephant remember

Elephant prompts:

    What should I remember?

The user enters:

    Elephant is a conductor of AIs and tools.

Elephant responds:

    Stored memory 20260808-001

The user can then run:

    elephant list

and receive:

    20260808-001  fact  Elephant is a conductor of AIs and tools.

The user can retrieve the complete record with:

    elephant show 20260808-001

Elephant then displays the stored memory.

## Initial Commands

Version 0.1 needs only three commands.

### remember

Create a new durable memory.

    elephant remember

The command should:

1. accept content

2. assign an identifier

3. identify the source

4. create a timestamp

5. write the Markdown file

6. report the identifier

### list

Display the memories currently stored.

    elephant list

The first implementation does not need sophisticated search.

A simple chronological listing is sufficient.

### show

Retrieve one memory by identifier.

    elephant show 20260808-001

The command should display the complete record in a human-readable form.

## Source

Version 0.1 should preserve the source of every memory.

Initially, supported values may be limited to:

    human

    ai

For a command entered directly by the user:

    source: human

Later versions may support more detailed provenance such as:

    source:

      type: human

      identity: Alexander

or:

    source:

      type: ai

      provider: OpenAI

      model: ...

Detailed provenance is not required for the first implementation.

## Memory Types

Version 0.1 should support a small set of memory types.

Initially:

    fact

    preference

    decision

    observation

    note

The default may simply be:

    note

The purpose of the type field is to demonstrate structured memory without requiring a complete ontology.

## Git

The first Elephant does not need to automate Git.

The `memories/` directory will live inside the Elephant Git repository.

That means memories can already benefit from:

- version history

- backup

- synchronization

- inspection of changes

- rollback

Automatic commits may be added later.

For version 0.1, manual Git commits are acceptable.

## Error Handling

The first implementation should handle a few obvious failures cleanly.

Examples include:

- missing memories directory

- invalid memory identifier

- unreadable memory file

- inability to write a new file

Errors should be understandable to a human.

For example:

    Elephant could not find memory 20260808-017.

A Python traceback should not be the normal user experience.

## Tests

The first version should have automated tests for its core behavior.

At minimum:

    create a memory

    confirm that the file exists

    read the memory back

    confirm that the content matches

    list stored memories

    request a nonexistent memory

The test suite does not need to be large.

It needs to prove that Elephant remembers.

## What Version 0.1 Will Not Do

Version 0.1 will not include:

- semantic search

- embeddings

- vector databases

- cloud synchronization

- automatic Git commits

- multiple AI providers

- Google integration

- email integration

- calendar integration

- autonomous workflows

- complex relationship graphs

- automatic contradiction resolution

- automatic supersession

- a graphical interface

Those capabilities may become useful later.

Building them now would obscure the experiment.

## The First Demonstration

The first successful Elephant demonstration should be extremely simple.

A human tells Elephant:

    Remember that the purpose of Elephant is

    durable human-AI continuity.

Elephant stores the record.

The program exits.

Later, perhaps after the computer or AI session has been restarted, the human asks Elephant to retrieve that memory.

Elephant finds it and displays it.

That moment demonstrates the central property of the system:

**The memory survives the conversation.**

## Success Criteria

Elephant 0.1 is successful when all of the following are true:

- a human can create a memory

- the memory becomes a durable Markdown file

- the memory contains its source and timestamp

- Elephant can list the memory

- Elephant can retrieve it by identifier

- the record remains understandable without running Elephant

- automated tests verify the basic memory loop

Nothing more is required for version 0.1.

## What Comes After

Once this works, we can evaluate the system based on actual use.

The next question will not be:

    What feature can we add?

It will be:

    What prevents this small Elephant from being genuinely useful?

That answer should determine version 0.2.

Elephant should grow from demonstrated need rather than speculative complexity.

The first Elephant only needs to remember one thing and find it again.

That is where we begin.

**An elephant remembers what matters.**

