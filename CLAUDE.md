# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle exec rake          # run tests + rubocop (default task)
bundle exec rake test     # run tests only
bundle exec rubocop       # lint
bundle exec srb tc        # Sorbet type checking
bin/console               # IRB with soren loaded
bin/setup                 # install dependencies (first time)
```

Run a single test file:
```bash
bundle exec ruby -Ilib:test test/soren/connection_test.rb
```

Before finishing any change, all three must pass: `rake test`, `srb tc`, `rubocop`.

## Architecture

Soren is a low-level Ruby HTTP client gem (Ruby >= 3.2). The public API is three classes: `Connection`, `Request`, `Response`.

**Request flow:**
1. Caller builds a `Soren::Request` (method, target, headers, body)
2. Caller creates a `Soren::Connection` (host/port/scheme or uri, plus timeout options)
3. `connection.send(request)` opens a TCP/SSL socket, writes the request, reads and parses the response, returns a `Soren::Response`

**Layer structure:**

| Layer | Location | Role |
|---|---|---|
| Facades | `lib/soren/{connection,request,response}.rb` | Public API; compose type classes and orchestrate layers below |
| Types | `lib/soren/types/` | Validate and normalize every input; raise `Soren::Error::ArgumentError` on bad input |
| Socket | `lib/soren/socket/` | `IO` writes the request and reads raw bytes; `Reader` handles line-by-line reads with deadline enforcement |
| Parsers | `lib/soren/parsers/response*.rb` | Parse HTTP status line, headers, and body (chunked, gzip, deflate) |
| Decoders | `lib/soren/decoders/` | Gzip and deflate decompression |
| Deadline | `lib/soren/deadline.rb` | Monotonic timer shared across connect/write/read phases |
| Errors | `lib/soren/error/` | Domain-specific hierarchy under `Soren::Error::Base` |

**Type classes** (`lib/soren/types/`) mirror the three facade namespaces (`connection/`, `request/`, `response/`) plus `options/`. Facades instantiate these to validate inputs before doing any I/O.

**Error hierarchy:** All errors inherit `Soren::Error::Base < StandardError`. Specific classes: `ArgumentError`, `ConnectionError`, `TimeoutError`, `DNSFailure`, `ConnectionRefused`, `SSLError`, `ReadError`, `WriteTimeout`, `ReadTimeout`, `ParseError`, `ProtocolError`. Always rescue specific classes and re-raise as domain errors, preserving message context.

## Conventions

**File headers** — all files under `lib/` must start with:
```ruby
# typed: strict
# frozen_string_literal: true
```

**Sorbet type annotations** — use inline comment style, not RBI blocks:
```ruby
#: (host: String, port: Integer) -> void
```

**Tests** mirror source structure under `test/` (e.g. `lib/soren/connection.rb` → `test/soren/connection_test.rb`). Prefer real internet-backed execution over mocks; stubs only for error paths that can't be triggered live. If a test fails due to connectivity, re-run up to 3 times before treating it as a code failure.

**Scope discipline** — keep edits focused; don't reformat unrelated code or extend the public API beyond what the task requires.
