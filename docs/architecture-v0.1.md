# Elephant — Technical Architecture v0.1

Status: initial design proposal, not an implementation.

## Mission
Elephant is a durable, auditable, model-independent system for human–AI collaboration. It preserves conversations, decisions, evidence, and corrections across sessions and model providers.

## Components
1. Interface: a single conversation with Elephant.
2. Ada orchestrator: classify tasks, select available models automatically, route requests, and aggregate results.
3. Model adapters: provider-neutral request/response contracts; Python adapters are optional where libraries warrant them.
4. Memory: SQLite persistence with immutable historical events, versioned interpretations, provenance, and retrieval.
5. Learning: track task outcomes and improve routing and retrieval without self-modifying production code.
6. Supervisor: enforce permissions, budgets, privacy boundaries, and approval gates.

## Decision rules
- Elephant chooses the model by default; a manual override may be offered.
- Consider capability, measured quality, latency, cost, privacy, and availability. Do not assume model quality without evaluation.
- Multiple models may be consulted for difficult tasks when authorized and within budget.
- Record which models were used and why, subject to privacy controls.

## Memory invariants
- Preserve original events; corrections append new events that reference earlier records.
- Separate user statements, externally sourced facts, hypotheses, model outputs, and verified outcomes.
- Attach timestamps, provenance, confidence/evidence status, and access controls.
- Support user-directed deletion and retention rules; append-only history must not prevent authorized erasure.
- Avoid automatically treating unverified model outputs as facts.

## Safety and operations
- No autonomous modification or deployment of production source code.
- Proposed code changes require human approval and tests.
- Background work is opt-in, bounded by resource and cost limits, and interruptible.
- External services receive only task-relevant information under explicit permissions.
- Failure of a model or adapter must not corrupt memory.

## Initial implementation plan
1. Define Ada package interfaces and SQLite schema.
2. Build event logging, versioned memory, and retrieval tests.
3. Implement one provider adapter with a mock adapter for offline tests.
4. Add task routing, model selection, and decision logs.
5. Add controlled background scheduling and measurable learning experiments.

## Open design questions
- Local operating environment and service lifecycle.
- Provider credentials and maximum spending.
- Retention, encryption, and export requirements.
- Evaluation criteria for routing and learning.
