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

## Implementation Languages

Elephant deliberately separates its core from the tools and services it conducts.

The initial architecture uses three programming languages for distinct purposes:

- **Ada** for the Elephant Core

- **Python** for rapidly developing Elephant Keys and taking advantage of its large software ecosystem

- **Rust** for Keys or other components that require greater performance, security, or rigor

These are implementation choices, not restrictions on the architecture.

Elephant should remain capable of incorporating components written in other languages when useful.

### Ada: The Core

The Elephant Core will be implemented in Ada.

Ada was chosen because the core should emphasize:

- readability

- explicit structure

- strong typing

- reliability

- maintainability

- long-term durability

- understandable interfaces

The core contains the behavior that defines Elephant itself.

It should remain relatively small and should not accumulate dependencies merely because an external service requires them.

The Elephant Core should not need to understand the implementation details of every system it conducts.

Instead, external capabilities are reached through Keys.

### Python: Ecosystem Keys

Python is particularly valuable because of its enormous ecosystem.

Many AI systems, APIs, scientific packages, databases, automation systems, and other services already provide mature Python libraries.

Elephant can take advantage of that ecosystem without making Python a permanent dependency of the core.

A Python Key can translate between an external system and the Elephant Key Protocol.

Python is therefore a preferred language for:

- rapidly developing new Keys

- experimenting with integrations

- using existing Python libraries

- prototyping new Elephant capabilities

- connecting to services whose best-supported interface is Python

A Python Key can be replaced without replacing Elephant.

### Rust: Hardened Keys

Some Keys may eventually require characteristics beyond those needed during initial development.

A Key may become:

- performance-critical

- security-critical

- resource-intensive

- widely deployed

- difficult to distribute reliably with its Python dependencies

Such a Key may be reimplemented in Rust.

Rust provides strong memory-safety guarantees while retaining the performance and deployment characteristics of compiled systems software.

A typical development path may therefore be:

    Python prototype

          |

          v

    Working Elephant Key

          |

          v

    Proven requirement

          |

          v

    Rust implementation when justified

Rewriting a Python Key in Rust should not require changing the Elephant Core.

Both implementations should present the same interface to Elephant.

## Elephant Keys

An Elephant Key is a connector between Elephant and another system.

The name reflects its purpose:

**A Key allows Elephant to unlock and use a capability that exists outside Elephant itself.**

Possible Keys might connect Elephant to:

- an AI provider

- a local AI model

- Git

- GitHub

- Google services

- email

- calendars

- search engines

- databases

- cloud storage

- scientific software

- operating-system services

- command-line programs

- other applications

A Key should do one job well.

Elephant should not incorporate an external system's implementation details into its core merely to communicate with that system.

Instead:

    Elephant Core

          |

          v

    Elephant Key Protocol

          |

          v

    Key

          |

          v

    External System

The external system can change without requiring the Elephant Core to change.

The Key can change without requiring the external system or Elephant Core to change.

## The Elephant Key Protocol

All Keys should communicate with Elephant through a stable, documented interface.

This interface is the **Elephant Key Protocol**.

The protocol should describe what information passes between Elephant and a Key without requiring either side to know how the other is implemented.

For example:

    Elephant Core

          |

          +--> Python Key --> AI service

          |

          +--> Python Key --> Google Calendar

          |

          +--> Rust Key ----> high-performance service

          |

          +--> Ada Key -----> local capability

          |

          +--> other Key ---> future system

The protocol should be language-independent.

A Key should not need to be written in Ada, Python, or Rust.

Any implementation that correctly speaks the Elephant Key Protocol should be capable of becoming an Elephant Key.

This gives Elephant an important property:

**The implementation language of a component is replaceable.**

The first version of the Key Protocol should remain extremely small.

It should grow only when working Keys demonstrate the need for additional capabilities.

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

    +-- src/

    |     +-- elephant.adb

    |     +-- elephant.ads

    |

    +-- memories/

    |

    +-- tests/

Directories for Keys can be introduced when the first Key is actually needed.

For example:

    keys/

        python/

        rust/

The exact structure may change as we learn from the implementation.

The important distinction is between:

- Elephant Core

- Elephant Keys

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

An Ada exception traceback or other internal diagnostic should not be the normal user experience.

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

- a large collection of Keys

Those capabilities may become useful later.

Building them now would obscure the experiment.

The Key architecture can be defined before Elephant actually needs its first external Key.

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

