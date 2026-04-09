# Soren Project Conventions

This file defines conventions for AI-assisted changes in this repository.

## Mandatory Verification

For every code change, always run all commands below before considering work complete:

```bash
bundle exec rake test
bundle exec srb tc
bundle exec rubocop
```

Do not skip Sorbet type checking when code has changed.
Do not skip RuboCop; fix linter issues introduced by your changes.

## Scope And Intent

- Preserve existing public APIs unless the task explicitly requires API changes.
- Prefer small, focused edits over broad refactors.
- Do not rewrite formatting across unrelated lines.

## Runtime And Tooling

- Language: Ruby (gem project).
- Tests: Minitest.
- Linting: RuboCop with many style cops relaxed in [.rubocop.yml](../.rubocop.yml).
- Type discipline: Sorbet-style strictness markers plus inline type comments.

## File Headers

For library files under `lib/`, keep these two lines at the top:

```ruby
# typed: strict
# frozen_string_literal: true
```

For test files, keep existing style (usually only frozen string literal, sometimes none).

## Type Annotation Pattern

This project uses inline Sorbet-like signature comments in this form:

```ruby
#: (arg: untyped) -> void
```

Conventions:

- Add a signature comment before public and private methods when touching typed files.
- Use existing local style (`untyped`, `String`, `Integer`, `bool`, `Type?`, `Hash[...]`, `Array[...]`).
- For values accepted from external callers, type input parameters as `untyped` and narrow them through explicit validation/coercion inside the method.
- Do not use `untyped` as a default fix for Sorbet errors; prefer specific types or narrow unions first, and only use `untyped` when there is no practical typed alternative.
- For complex hashes, `Hash[KeyType, untyped]` is acceptable for the value type when a precise value union would be excessively complex or brittle.
- Preserve inline instance variable type comments:

```ruby
@value = normalize(value) #: String
```

## Namespacing And Structure

- Main namespace is `Soren`.
- Subsystems are nested modules/classes, for example:
  - `Soren::Types::Request::*`
  - `Soren::Types::Response::*`
  - `Soren::Parsers::*`
  - `Soren::Decoders::*`
  - `Soren::Error::*`
- Place new classes in files that mirror their constant path.
  - Example: `Soren::Types::Config` -> `lib/soren/types/config.rb`.

## Validation And Normalization Pattern

- Validation logic belongs in dedicated type objects under `lib/soren/types/`.
- Facade/domain classes should compose those type classes rather than duplicating validation logic.
- Raise `Soren::Error::ArgumentError` for invalid constructor input intended as caller error.

## Error Handling Conventions

Use the existing error taxonomy under `Soren::Error`.

- Connection-layer failures map to connection-related errors.
- Parse/format/content failures map to parse/protocol/read errors.
- Keep error messages explicit and deterministic for tests.

When adding rescue blocks:

- Rescue specific exceptions first.
- Re-raise as domain errors from `Soren::Error::*`.
- Preserve useful original message context.

## Requires And Dependencies

- Prefer `require_relative` for internal project files.
- Keep requires grouped at the top of each file.
- Follow nearby quote style within the file (`'` is common in `lib/soren/*`).

## Formatting Style To Preserve

- Existing code intentionally allows extra blank lines and alignment choices.
- Keep current indentation and spacing style of the touched file.
- Do not enforce generic style defaults that conflict with repository patterns.

## Tests

When behavior changes, add or update Minitest coverage.

Test conventions:

- Test file location mirrors source location under `test/`.
- Use clear method names: `test_*`.
- Prefer explicit assertions and exact message checks for raised errors.
- Use `assert_raises(Soren::Error::...)` for domain errors.

## Typical Change Workflow

1. Update implementation in the smallest relevant file set.
2. Update or add tests near the changed behavior.
3. Run:

```bash
bundle exec rake test
```

4. Run Sorbet type checking:

```bash
bundle exec srb tc
```

5. Run RuboCop and fix lint issues:

```bash
bundle exec rubocop
```

## What To Avoid

- Introducing new dependencies unless necessary.
- Mixing unrelated refactors with feature/bugfix changes.
- Replacing the project's type-comment style with a different annotation system.
- Renaming constants/files without updating all references and tests.
