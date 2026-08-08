# Elephant Data Model

> An elephant remembers what matters.

Elephant needs more than storage.

It needs a way to represent information so that it can remember where something came from, how reliable it is, what it relates to, and whether it is still current.

The data model should remain simple enough to understand, portable enough to survive changes in software, and flexible enough to evolve.

## 1. The Basic Unit: A Record

The fundamental unit of Elephant memory is a record.

A record represents something worth preserving.

Examples include:

- a fact

- a preference

- a decision

- an observation

- a task

- an event

- a document

- a relationship

- a question

- a conclusion

A record should contain the information itself plus enough context to understand it later.

## 2. Core Record Fields

A record may contain fields such as:

    id

    type

    content

    source

    created

    modified

    confidence

    context

    relationships

    status

    supersedes

    tags

Not every record requires every field.

The model should allow simple information to remain simple.

## 3. Identity

Every durable record should have a stable identity.

    id

The identifier allows other records to refer to it without depending upon its filename, wording, or physical storage location.

Identifiers should remain stable even when the record is updated or moved.

## 4. Type

The `type` field describes what kind of information the record contains.

Possible types include:

    fact

    preference

    decision

    observation

    task

    event

    document

    person

    organization

    project

    relationship

    question

    conclusion

Types should be extensible.

Elephant should not require every future kind of information to be predicted in advance.

## 5. Content

The `content` field contains the information being preserved.

For example:

    Elephant uses Git for versioning human-readable project knowledge.

Content may be plain text or structured data depending on the record.

Human readability should be preferred where practical.

## 6. Source

Elephant should remember where information came from.

Possible sources include:

    human

    AI

    document

    email

    website

    API

    database

    sensor

    software tool

A source may also identify a particular person, document, message, URL, repository, or system.

For example:

    source:

      type: human

      identity: Alexander

or:

    source:

      type: document

      document: ARCHITECTURE.md

The distinction matters.

Something stated by the human is different from something inferred by an AI.

## 7. Time

Records should preserve relevant timestamps.

At minimum:

    created

    modified

Some records may also need:

    observed

    effective

    expires

These represent different concepts.

For example, Elephant might learn something today that became true three months ago.

The time Elephant learned something is not necessarily the time the fact became true.

## 8. Confidence

Some information is certain.

Some is uncertain.

Some is an inference.

Elephant should be capable of representing that distinction.

For example:

    confidence: confirmed

or:

    confidence: likely

or:

    confidence: uncertain

Confidence should not pretend to mathematical precision where none exists.

Its purpose is to prevent uncertain information from silently becoming established fact.

## 9. Context

Facts rarely exist in isolation.

A record may belong to:

- a project

- a conversation

- a person

- a place

- an organization

- a period of time

- another record

Context helps Elephant determine when remembered information is relevant.

For example:

    context:

      project: Elephant

The same word or statement may mean something entirely different in another context.

## 10. Relationships

Elephant should represent relationships between records.

Examples include:

    belongs-to

    refers-to

    caused-by

    derived-from

    supports

    contradicts

    depends-on

    replaces

    related-to

This allows memory to become a network rather than merely a collection of isolated notes.

For example:

    ARCHITECTURE.md

        |

        +-- belongs-to --> Elephant

        |

        +-- derived-from --> VISION.md

        |

        +-- constrained-by --> PRINCIPLES.md

Relationships should be understandable without requiring a proprietary graph database.

## 11. Decisions

Decisions deserve special treatment because remembering only the final answer loses important information.

A decision record should be able to preserve:

    question

    alternatives

    decision

    reasoning

    source

    timestamp

    status

For example:

    question:

      Should Elephant require all components to be open source?

    decision:

      No.

    reasoning:

      Elephant may use proprietary services when useful,

      provided durable information is not dependent upon them

      and components remain replaceable.

This allows a future human or AI to understand not merely what was chosen, but why.

## 12. Supersession

Elephant should generally avoid silently overwriting durable knowledge.

When information changes, the new record may supersede the old one.

For example:

    Record A

    status: superseded

    Record B

    supersedes: Record A

The earlier information remains available as history.

This is especially important for:

- decisions

- plans

- preferences

- policies

- measurements

- interpretations

The goal is not to preserve every trivial edit forever.

The goal is to preserve meaningful change.

## 13. Contradictions

Real information is messy.

Two sources may disagree.

Elephant should not automatically erase one because another exists.

Instead, it should be possible to record:

    Record A

        |

        contradicts

        |

    Record B

A later process, human or AI, may resolve the contradiction.

Until then, Elephant should preserve the uncertainty.

## 14. Facts and Inferences

Elephant should distinguish between what a source actually states and what an AI concludes from it.

For example:

    observation:

      The repository contains README.md, VISION.md,

      PRINCIPLES.md, LICENSE, and ARCHITECTURE.md.

An AI might infer:

    inference:

      Elephant is currently in an early architectural

      design stage.

Those are different records.

The inference may be useful, but it should not masquerade as an observed fact.

## 15. Projects

Projects provide a natural organizational boundary.

A project record may include:

    id

    name

    description

    status

    repositories

    documents

    people

    decisions

    tasks

For example:

    project:

      name: Elephant

      description: Open-source durability and orchestration

                   layer for human-AI collaboration.

Project memory should remain accessible across conversations and AI systems.

## 16. People

Elephant may need to represent people and their relationships to projects and information.

A person record should contain only information appropriate for the purpose for which it is stored.

Possible fields include:

    name

    preferred-name

    roles

    relationships

    contact-references

    notes

Sensitive information should not be collected merely because it can be collected.

Memory should serve the human rather than becoming indiscriminate surveillance.

## 17. Tasks and Actions

A task represents something that should happen.

Possible fields include:

    description

    created

    due

    status

    project

    dependencies

    responsible-party

Typical statuses might include:

    proposed

    pending

    active

    completed

    cancelled

An action is something that actually happened.

Tasks and actions should not be confused.

    task:

      Commit DATA-MODEL.md.

    action:

      DATA-MODEL.md committed to GitHub.

This distinction allows Elephant to understand the difference between intention and history.

## 18. Documents

Documents may be records themselves or may be referenced by records.

Elephant should avoid unnecessarily duplicating entire documents when a durable original already exists.

Instead, it may preserve:

    document identity

    location

    version

    checksum

    relevant sections

    relationships

    metadata

The original document remains the authoritative artifact where appropriate.

## 19. Storage Representation

The conceptual data model should not depend upon one database technology.

A record might initially be represented in Markdown:

    # Decision: Open and Proprietary Components

    Status: Active

    Project: Elephant

    Elephant may use both open-source and proprietary

    components provided that important durable information

    remains portable and components remain replaceable.

Later, the same conceptual record might be represented in JSON, YAML, SQLite, PostgreSQL, or another system.

The meaning of the record should survive the change in storage technology.

## 20. Human Readability

Where practical, Elephant's durable memory should remain understandable without Elephant.

A human should be able to inspect important records with ordinary tools.

This principle favors formats such as:

- Markdown

- plain text

- JSON

- YAML

- CSV

- standard databases

Machine efficiency matters.

Human recoverability matters more.

## 21. Minimum Viable Data Model

The first working Elephant does not need every feature described here.

A minimal record could contain:

    id

    type

    content

    source

    timestamp

Additional structure should be introduced when actual use demonstrates the need for it.

The data model should grow from experience rather than speculation.

## 22. The Durability Test

Every important Elephant record should ultimately pass a simple test:

**If the AI, application, vendor, and current computer disappeared tomorrow, could the human still recover and understand what mattered?**

If the answer is yes, Elephant is doing its job.

**An elephant remembers what matters.**

