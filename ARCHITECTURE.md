# Elephant Architecture

> An elephant remembers what matters.

Elephant is a durability and orchestration layer for human-AI collaboration.

Its architecture is designed around a simple idea:

**Elephant should not try to become every tool. It should conduct the tools that already exist, preserve the important results, and provide open alternatives where important capabilities would otherwise depend on a single vendor.**

## 1. Architectural Role

Elephant sits between the human, artificial intelligences, tools, services, and durable storage.

Conceptually:

    Human

      |

      v

    Elephant

      |

      +----------+----------+

      |          |          |

      v          v          v

     AIs       Tools      Services

      |          |          |

      +----------+----------+

                 |

                 v

           Durable Memory

                 |

                 v

        Human-Owned Records

Elephant is the conductor.

The individual AI models, applications, APIs, search engines, databases, note systems, calendars, repositories, and other services are the orchestra.

Elephant does not require every component to come from the same company or use the same technology.

## 2. Core Architectural Principles

### Human ownership

The human's information should remain under human control.

Important information should be exportable into ordinary, documented formats rather than being trapped inside a proprietary application.

### Replaceable components

AI models and external services should be treated as replaceable components.

Elephant should be able to work with multiple providers rather than assuming that one AI, one cloud platform, or one vendor will exist forever.

### Open interfaces

Components should communicate through documented interfaces.

Where practical, Elephant should favor open standards and open-source software.

### Durable records

Conversation is temporary.

Important results should become durable records.

Elephant should distinguish between transient interaction and information that deserves to survive beyond the current conversation, application, model, or device.

### Graceful degradation

Elephant should remain useful when individual services are unavailable.

Loss of one AI provider, API, cloud service, or proprietary product should not destroy the user's accumulated knowledge.

## 3. Major Components

Elephant can be understood as a set of cooperating layers.

### 3.1 Human Interface Layer

This is where the human communicates with Elephant.

Interfaces may include:

- conversational AI

- command-line tools

- web applications

- mobile applications

- notebooks

- editors

- voice interfaces

- automation interfaces

The interface is not Elephant itself.

Different interfaces should be capable of accessing the same underlying durable information.

### 3.2 Orchestration Layer

The orchestration layer is the conductor.

It determines which tool, model, service, or repository should perform a task.

For example, Elephant might route different work to:

- a local language model

- a commercial AI service

- a search engine

- Git

- a database

- a calendar

- email

- a document system

- a code execution environment

- a specialized scientific or analytical package

The orchestration layer should make these components cooperate without requiring the user to manually move information between them.

### 3.3 AI Adapter Layer

Elephant should support multiple artificial intelligence systems through adapters.

An adapter translates between Elephant's internal representation and a particular AI provider.

Possible providers include commercial services, locally hosted models, and open-source models.

A change of AI provider should not require redesigning Elephant itself.

The architecture should permit several models to participate in the same project, each selected according to its strengths, cost, availability, privacy characteristics, or capabilities.

### 3.4 Tool Adapter Layer

Non-AI tools are equally important.

Elephant should be able to invoke existing software rather than attempting to reproduce every capability internally.

Potential integrations include:

- Git and GitHub

- local filesystems

- Markdown

- SQLite

- PostgreSQL

- search engines

- email systems

- calendars

- task managers

- office applications

- scientific software

- programming environments

- command-line utilities

- cloud storage

- local storage

Adapters isolate vendor-specific behavior from Elephant's core.

### 3.5 Memory Layer

Memory is one of Elephant's defining responsibilities.

The memory layer determines what information should persist and how it should be retrieved.

Memory may include several forms:

#### Working memory

Information needed for the current task or conversation.

#### Project memory

Information associated with a particular project.

#### Personal memory

Long-lived information the human explicitly wants Elephant to retain.

#### Reference memory

Documents, notes, repositories, correspondence, datasets, and other source material.

#### Decision history

Important decisions should retain enough context to answer:

- What was decided?

- When was it decided?

- Why was it decided?

- What evidence supported the decision?

- What later replaced or modified it?

Elephant should preserve provenance wherever practical.

## 4. Durable Storage

Elephant should use ordinary durable formats whenever possible.

Examples include:

- Markdown

- plain text

- JSON

- YAML

- CSV

- SQLite

- Git repositories

- standard image formats

- standard document formats

The storage architecture should separate the durable information from the program used to access it.

If Elephant disappeared tomorrow, the human should still be able to read the important records.

## 5. Git as a Durability Mechanism

Git is particularly useful to Elephant because it provides:

- version history

- distributed copies

- human-readable change tracking

- branching

- rollback

- synchronization

- provenance

- compatibility with existing development infrastructure

Git should not necessarily store everything.

Large binary files, databases, credentials, and rapidly changing machine state may require other storage mechanisms.

But human-readable project knowledge is often an excellent fit for Git.

## 6. Event and Action Model

Elephant should distinguish between information and actions.

Examples of information:

    Alexander prefers Markdown for project documentation.

Examples of actions:

    Create ARCHITECTURE.md.

    Send an email.

    Run a search.

    Commit a file.

    Schedule a reminder.

Actions should be explicit and auditable.

Where an action affects an external system, Elephant should record enough information to understand what occurred.

## 7. Provenance

Elephant should attempt to preserve where information came from.

A durable fact may have originated from:

- the human

- an AI inference

- a document

- a website

- an API

- an email

- a database

- a sensor

- another program

These are not equivalent sources.

The architecture should make it possible to distinguish between them.

Where appropriate, Elephant should preserve:

    value

    source

    timestamp

    confidence

    context

    superseded-by

This makes memory inspectable rather than mysterious.

## 8. The Conductor Model

Elephant's most important architectural idea is orchestration.

Many excellent components already exist.

Elephant should use them.

For example, one workflow might involve:

    Human request

         |

         v

    Elephant

         |

         +--> AI model for reasoning

         |

         +--> Search engine for current information

         |

         +--> Python for computation

         |

         +--> Git for versioning

         |

         +--> Markdown for durable documentation

         |

         +--> Calendar for future action

         |

         +--> Database for structured records

         |

         v

    Durable result

No single component needs to understand the entire workflow.

Elephant coordinates them.

## 9. Open Source and Proprietary Services

Elephant should be pragmatic.

A proprietary service should not be rejected merely because it is proprietary.

If Google, OpenAI, Apple, Microsoft, Anthropic, GitHub, or another provider offers a useful service, Elephant should be capable of using it.

However, Elephant should avoid making the user's durable information dependent upon that service.

Where a proprietary component performs an important structural role, the project should investigate whether an open-source equivalent already exists.

If none exists, Elephant may eventually provide or encourage development of an open alternative.

The objective is not ideological purity.

The objective is **replaceability**.

## 10. Credentials and Secrets

Credentials must not be stored with ordinary project memory.

API keys, passwords, tokens, and other secrets should be managed through dedicated secret-storage mechanisms.

Elephant should refer to credentials by logical identity rather than embedding them directly in durable documents.

For example:

    github.personal

    google.calendar

    openai.primary

The implementation behind those names may vary by operating system or deployment.

## 11. Local and Cloud Operation

Elephant should not require a purely local or purely cloud architecture.

A deployment may combine both.

For example:

    Local machine

        |

        +-- local files

        +-- local database

        +-- local AI model

        |

        v

    Elephant

        |

        +-- cloud AI

        +-- GitHub

        +-- Google services

        +-- remote storage

Users should be able to choose where different categories of information live.

## 12. Architectural Independence

Elephant should survive changes in the technology around it.

AI models will change.

Companies will change.

APIs will disappear.

Operating systems will change.

Today's dominant tools may become tomorrow's abandoned platforms.

The durable layer should therefore depend as little as practical on any particular vendor.

Elephant should be designed so that components can be replaced without losing the human's accumulated work.

## 13. Initial Implementation Strategy

The first versions of Elephant do not need to implement the entire architecture.

Development should begin with the simplest useful system.

An initial Elephant implementation may consist largely of:

    Markdown

    +

    Git

    +

    AI

    +

    small orchestration scripts

From there, additional adapters and services can be added incrementally.

The architecture should evolve through working software rather than attempting to design the entire future system in advance.

## 14. Long-Term Direction

Over time, Elephant may become a common interface through which a human can work with many artificial intelligences and software systems while maintaining one continuous body of durable knowledge.

The AI may change.

The application may change.

The computer may change.

The service provider may change.

The knowledge should remain.

That is the architectural purpose of Elephant.

**An elephant remembers what matters.**