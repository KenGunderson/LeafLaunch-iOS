# Implement a Feature

This workflow owns discovery and sequencing. The [implementation guide](IMPLEMENTATION_BEST_PRACTICES.md) owns coding rules, and [AGENTS.md](../../AGENTS.md) routes tasks to the relevant owners.

## Establish the contract

Read the matching task references, applicable guide sections, closest current implementation, direct callers, and affected live/mock registrations. Use the existing [customer architecture](../reference/CUSTOMER_ARCHITECTURE.md), [customer workflow](../../UX-CONTRACT.md), and [design contract](../../DESIGN.md) where relevant. Distinguish intended behavior from observed source when they disagree.

Reuse approved decisions. A small change needs a brief scope statement; a change crossing owners benefits from a compact list of owners, files, local examples, and integration obligations. Ask only about unresolved product choices or authority. Routine choices within established patterns do not need another approval gate.

Search app-owned components first, then resolved Rune source. The [component catalog](../reference/UBIQUITOUS_COMPONENTS_GLOBAL.md) is a discovery aid; verify signatures against the pinned dependency. No global catalog regeneration or installed linter skill is a prerequisite for applying local rules. Add a custom component only for a demonstrated gap.

## Deliver complete behavior

Implement in dependency order, skipping irrelevant steps:

1. Define focused models near their owning feature/service, with independent models in separate files.
2. Update affected service/API protocols, implementations, mock behavior, fixtures, and registrations together.
3. Add ViewModel state, route/context setup, lifecycle, analytics, cancellation, loading, and error handling. Preserve startup and single-flight/context exceptions.
4. Compose views with existing wrappers, active tokens, explicit spacing, and small named `@ContentBuilder` helpers. Preserve initial, empty, failure, retry, and refresh behavior.
5. Connect destinations, route payloads, sheets, tabs, previews, and mock resolution. Inspect actual callers; a file's presence does not establish integration.
6. Add new Swift files to both applicable explicit Xcode targets and inspect affected resources/configuration.
7. Update existing guidance, examples, or architecture descriptions when the change makes them inaccurate. Keep task routing and the documentation index current when adding or moving a guide.

This workflow does not require per-feature documents, a feature index, a domain glossary, or business-rule evidence records. Maintain the existing focused documentation according to the scope of the change.

## Verify and hand off

Inspect changed callers, ownership/cancellation paths, live/mock/preview wiring, navigation, analytics, theme behavior, and target membership as applicable. Use proportional source checks such as Swift syntax parsing, plist/JSON validation, local-link validation, and `git diff --check`. Static checks do not establish compilation or runtime behavior.

Do not run Xcode builds or tests unless explicitly requested. Do not write tests. Do not create a worktree, stage, commit, or push without authorization. Report the delivered behavior, meaningful decisions, checks performed, and material verification limits. Keep unrelated cleanup out of ordinary feature work; an explicitly requested adoption pass can cover its agreed repository-wide scope.
