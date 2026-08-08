# Elephant Roadmap

> An elephant remembers what matters.

This roadmap describes a practical path from Elephant's current design documents to a working system.

It is not a fixed schedule.

The roadmap should change as Elephant is built and as real experience reveals what is useful.

The guiding rule is simple:

**Build the smallest useful Elephant first.**

## Where We Are Now

Elephant currently has its conceptual foundation:

- README.md

- VISION.md

- PRINCIPLES.md

- ARCHITECTURE.md

- DATA-MODEL.md

- LICENSE

The next step is to move from documentation to working software.

## Phase 1: The Smallest Elephant

The first Elephant should do one thing well:

**Preserve something worth remembering in a durable, human-readable form.**

The initial implementation should be intentionally simple.

A first version may use:

    Markdown

    +

    Git

    +

    a small program or script

    +

    an AI

The goal is not to build the final architecture.

The goal is to prove the central idea.

### Initial capabilities

Elephant should be able to:

- accept information from a human or AI

- create a durable record

- identify the source

- timestamp the record

- store it in a human-readable format

- retrieve it later

- preserve its history with Git

At this stage, simplicity is more important than sophistication.

## Phase 2: Retrieval

Remembering information is useful only if Elephant can find it again.

The next milestone is reliable retrieval.

Elephant should be able to answer questions such as:

    What did we decide about proprietary services?

    Why did we make that decision?

    What do we currently believe about Elephant's architecture?

    What information has been superseded?

Retrieval may initially use ordinary text search.

More sophisticated indexing or semantic search can be added when necessary.

## Phase 3: Provenance

Once Elephant can store and retrieve information, it should become better at remembering where that information came from.

Records should be able to distinguish among:

- statements made by the human

- AI-generated conclusions

- documents

- websites

- APIs

- external tools

- other records

Elephant should make it difficult for an inference to silently become a fact.

## Phase 4: Decisions and Supersession

Elephant should begin preserving not only information but the history of important decisions.

It should be possible to determine:

- what was decided

- why it was decided

- what alternatives were considered

- what evidence was used

- whether the decision is still active

- what later decision replaced it

New information should be able to supersede old information without destroying history.

## Phase 5: First Tool Adapters

Elephant should begin conducting tools outside its own storage system.

Early adapters should be chosen because they solve real problems rather than because they demonstrate technology.

Likely early integrations include:

- Git

- GitHub

- local files

- search

- calendars

- email

- databases

- command-line tools

Each adapter should expose a small, documented interface to Elephant.

## Phase 6: Multiple AIs

Elephant should not depend upon one artificial intelligence provider.

Once the basic system works, Elephant should support multiple AI adapters.

These may include:

- commercial AI services

- open-source models

- locally running models

- specialized models

Elephant should be able to select an AI according to the needs of a task.

Selection may consider:

- capability

- privacy

- cost

- speed

- availability

- context requirements

- specialization

The durable memory should remain independent of whichever AI is currently being used.

## Phase 7: The Conductor

At this point, Elephant begins to become the system described in the architecture.

A single human request may involve several components.

For example:

    Human

      |

      v

    Elephant

      |

      +--> retrieve project memory

      |

      +--> ask an AI to reason

      |

      +--> search for current information

      |

      +--> run a computation

      |

      +--> update a document

      |

      +--> commit the change

      |

      +--> schedule a future action

      |

      v

    Durable result

Elephant coordinates the workflow while preserving what matters.

## Phase 8: Open Alternatives

Elephant should identify places where important functionality depends upon proprietary services.

For each dependency, ask:

    Is there already a good open-source alternative?

If yes, Elephant should attempt to support it.

If not, ask:

    Is this capability important enough that an open alternative should exist?

Elephant may then encourage, integrate, or eventually develop an open implementation.

The objective is not to replace proprietary software merely because it is proprietary.

The objective is to ensure that no essential part of the human's durable knowledge depends permanently upon one vendor.

## Phase 9: Portability

Elephant should be tested against failure.

Ask:

    What happens if this AI disappears?

    What happens if this API is discontinued?

    What happens if this application is abandoned?

    What happens if the user changes computers?

    What happens if the repository moves?

    What happens if Elephant itself disappears?

Important information should remain recoverable.

A successful Elephant installation should be capable of being reconstructed from durable records and documented configuration.

## Phase 10: A Personal Knowledge Continuity Layer

The long-term goal is larger than a memory application.

Elephant should provide continuity across:

- conversations

- projects

- AI models

- applications

- computers

- services

- years

A human should not have to reconstruct their working relationship every time the technology changes.

Different AIs may come and go.

Different tools may come and go.

Elephant preserves the continuity.

## Development Philosophy

Elephant should grow through use.

Do not build a complex feature because the architecture permits it.

Build it because a real workflow requires it.

Prefer:

    working software over speculative infrastructure

    ordinary formats over proprietary formats

    small interfaces over deep coupling

    replaceable components over permanent dependencies

    human-readable records over opaque state

    demonstrated needs over imagined needs

The architecture describes where Elephant can go.

The roadmap describes how to start walking there.

## Immediate Next Milestone

The next milestone is deliberately small:

**Build an Elephant that can create, preserve, and retrieve one durable memory record.**

That will be Elephant's first step from an idea into working software.

**An elephant remembers what matters.**

