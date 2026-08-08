# Elephant Principles

> An elephant remembers what matters.

Elephant is designed around a small set of principles. Architecture, implementation, and future development should be evaluated against them.

## 1. Preserve What Matters

Elephant exists to prevent valuable human-AI work from being unnecessarily lost.

Important conversations, ideas, decisions, discoveries, corrections, documents, relationships, and context should be preservable beyond the session in which they were created.

Preservation should be selective enough to remain useful and comprehensive enough to maintain continuity.

## 2. Preserve History

New information should not silently destroy old information.

When something changes, Elephant should preserve both the earlier state and the change.

Corrections, revisions, reversals, and disagreements are part of the historical record.

The past should remain recoverable.

## 3. Never Confuse Revision With Original

Elephant must distinguish between what was originally said or created and what was later changed.

A corrected record must not falsely imply that the corrected information was always present.

This distinction applies to conversations, documents, decisions, metadata, and other preserved information.

## 4. Conversations Are First-Class Artifacts

A conversation can contain information that no resulting document captures.

Elephant should therefore be capable of preserving conversations themselves, including their sequence and relevant context.

Documents created from conversations should be connected to their history rather than treated as replacements for it.

## 5. Preserve Provenance

Elephant should preserve where information came from whenever practical.

It should be possible to distinguish among human statements, AI-generated material, external sources, tool output, inference, and subsequent correction.

Information becomes more trustworthy when its history can be examined.

## 6. Human Intent Comes First

The human expresses what they are trying to accomplish.

Elephant should translate that intent into appropriate operations without requiring the human to manage unnecessary implementation details.

Tools serve the human's purpose.

The human should not have to serve the tools.

## 7. Elephant Is the Conductor, Not Every Instrument

Elephant should coordinate specialized tools rather than unnecessarily reproduce their capabilities.

Different artificial intelligences, open-source packages, local programs, cloud services, search systems, development tools, and other specialized systems can serve as instruments.

Elephant's responsibility is to understand the task, preserve continuity, and coordinate the appropriate capabilities.

## 8. Instruments Must Be Replaceable

No individual AI, vendor, service, model, or software package should become synonymous with Elephant.

Capabilities should be separated from particular providers wherever practical.

A better instrument should be adoptable without requiring the user's accumulated knowledge to be reconstructed.

Changing the instrument should not change the score.

## 9. Prefer Open Systems

Elephant itself should be open source.

Open formats, open protocols, open-source software, and locally controllable components should be preferred when they provide suitable capabilities.

Proprietary services may be used when they provide meaningful benefits, particularly when freely available, but they should not become unavoidable dependencies.

Where an important proprietary capability cannot reasonably be replaced, developing or supporting an open alternative may become an Elephant project.

## 10. Preserve Human Control

The human should be able to inspect, correct, export, move, and understand preserved information.

The human should also control which external systems Elephant may use and what information may be shared with them.

Convenience should not require surrendering control of the accumulated record.

## 11. Be Transparent

Elephant should make important operations understandable.

When practical, the system should make clear what it remembers, where information originated, what changed, what tool acted, and why an action occurred.

Hidden behavior weakens trust.

Transparency strengthens it.

## 12. Separate Memory From Intelligence

Elephant's durable knowledge should not depend upon the continued availability of the AI that helped create it.

Models can improve, disappear, or be replaced.

The accumulated record should remain.

Memory belongs to the collaboration, not to a particular model.

## 13. Favor Portable, Recoverable Data

Elephant should favor representations that can be understood without Elephant itself.

A durable archive should remain inspectable using ordinary tools whenever practical.

The failure or disappearance of Elephant must not mean the disappearance of the user's knowledge.

## 14. Design for Failure

Services will become unavailable.

Networks will fail.

APIs will change.

Models will disappear.

Files will become corrupted.

Software will contain bugs.

Elephant should assume these events will occur and design so that individual failures do not destroy the historical record.

## 15. Design for Decades

Short-term convenience should not unnecessarily compromise long-term durability.

Elephant should assume that its data may outlive today's applications, AI models, companies, operating systems, and developers.

The question is not merely whether something works today.

The question is whether what matters can still be understood tomorrow.

## 16. Build in the Open

Elephant should develop transparently.

Its architecture, principles, formats, limitations, and important design decisions should be documented.

Others should be able to inspect the project, criticize it, improve it, build upon it, and preserve it.

## The Test

When an architectural or implementation decision is unclear, ask:

Does this help Elephant remember what matters, preserve where it came from, keep the human in control, and remain useful when today's tools are gone?

If not, reconsider the decision.

