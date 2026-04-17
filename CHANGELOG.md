## [Unreleased]

## [0.1.3] - 2026-04-18

### Fixed

- Status line reason phrase is now optional per RFC 7230 §3.1.2 — responses without a reason phrase (e.g. `HTTP/1.1 200\r\n`) no longer raise `ParseError`
- 1xx informational responses (e.g. `100 Continue`) are now skipped transparently; the parser reads through them and returns the final response
- `no_body?` now correctly returns `true` for all 1xx status codes, not just 204 and 304

## [0.1.2] - 2026-04-17

- `Content-Length` header is now automatically set on requests with a body
- Header keys and values are now validated to be Strings

## [0.1.1] - 2026-04-17

- `Soren::Request` is now auto-required by `require 'soren'`

## [0.1.0] - 2026-02-26

- Initial release
