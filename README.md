# Soren

Soren is a simple HTTP client library. At the current moment the library provides the following functionality:

- HTTP and HTTPS support,
- configurable read/connect/write timeouts,
- response parsing with header/body decoding (including chunked, gzip, and deflate),
- explicit domain errors under `Soren::Error::*`.

`Soren` is currently supported by my own HTTP client abstraction layer [Sofia](https://github.com/KubaJadrzak/sofia) and further implemented (alongside Sofia) into my integration with Espago Payment System [Shopik](https://github.com/KubaJadrzak/Shopik), and everythings seems to be working pretty good :P

## Quick Start

```ruby
require 'soren'

connection = Soren::Connection.new(
	host:   'httpbin.org',
	port:   443,
	scheme: 'https'
)

request = Soren::Request.new(
	method:  'get',
	target:  '/anything/hello',
	headers: { 'Accept' => 'application/json' }
)

response = connection.send(request)

puts response.code       # Integer (e.g. 200)
puts response.message    # String  (e.g. "OK")
puts response.version    # String  (e.g. "HTTP/1.1")
puts response.headers    # Hash[String, Array[String]]
puts response.body       # String
```

## Creating Connections

You can initialize a connection in two ways.

### 1. Explicit host/port/scheme

```ruby
connection = Soren::Connection.new(
	host:   'example.com',
	port:   443,
	scheme: 'https'
)
```

### 2. URI object

```ruby
require 'uri'

connection = Soren::Connection.new(uri: URI('https://example.com'))
```

Do not use both at the same time!!!

## Options

Soren currently supports timeouts as configuration options, with the following three available:

- `connect_timeout`
- `write_timeout`
- `read_timeout`

Defaults:

- `connect_timeout`: `5.0`
- `write_timeout`: `10.0`
- `read_timeout`: `30.0`

Example:

```ruby
connection = Soren::Connection.new(
	host:    'httpbin.org',
	port:    443,
	scheme:  'https',
	options: {
		connect_timeout: 5.0,
		write_timeout: 10.0,
		read_timeout:  20.0,
	}
)
```

## Building Requests

```ruby
request = Soren::Request.new(
	method:  'post',
	target:  '/anything',
	headers: {
		'Accept' => 'application/json',
		'Content-Type' => 'application/json',
	},
	body: '{"hello":"world"}'
)
```

Supported methods include `get`, `post`, `put`, `patch`, `delete`.

## Error Handling

```ruby
begin
	response = connection.send(request)
	puts "#{response.code} #{response.message}"
rescue Soren::Error::TimeoutError => e
	warn "Timeout: #{e.message}"
rescue Soren::Error::DNSFailure => e
	warn "DNS failure: #{e.message}"
rescue Soren::Error::ConnectionRefused => e
	warn "Connection refused: #{e.message}"
rescue Soren::Error::SSLError => e
	warn "TLS/SSL error: #{e.message}"
rescue Soren::Error::ParseError, Soren::Error::ProtocolError => e
	warn "Invalid/unsupported HTTP response: #{e.message}"
rescue Soren::Error::Base => e
	warn "Soren error: #{e.class} - #{e.message}"
end
```

### Error Classes

- `Soren::Error::ArgumentError`
- `Soren::Error::ConnectionError`
- `Soren::Error::TimeoutError`
- `Soren::Error::DNSFailure`
- `Soren::Error::ConnectionRefused`
- `Soren::Error::SSLError`
- `Soren::Error::ReadError`
- `Soren::Error::WriteTimeout`
- `Soren::Error::ReadTimeout`
- `Soren::Error::ParseError`
- `Soren::Error::ProtocolError`

## Development

Setup:

```bash
bin/setup
```

Run checks:

```bash
bundle exec rake test
bundle exec srb tc
bundle exec rubocop
```

Open interactive console:

```bash
bin/console
```

## License

Soren is available under the [MIT License](LICENSE.txt).
