# typed: strict
# frozen_string_literal: true

require_relative 'types/response/status_code'
require_relative 'types/response/status_message'
require_relative 'types/response/version'
require_relative 'types/response/headers'
require_relative 'types/response/body'

module Soren
  class Response
    attr_reader :status_code #: Soren::Types::Response::StatusCode?
    attr_reader :status_message #: Soren::Types::Response::StatusMessage?
    attr_reader :version #: Soren::Types::Response::Version?
    attr_reader :headers #: Soren::Types::Response::Headers?
    attr_reader :body #: Soren::Types::Response::Body?

    #: (untyped) -> void
    def initialize(raw_response)
      parse(raw_response)
    end

    private

    #: (untyped) -> void
    def parse(raw_response)
      unless raw_response.is_a?(String) && !raw_response.empty?
        raise Soren::Error::ArgumentError, 'raw_response must be a non-empty String'
      end

      header_part, body_part = raw_response.split(/\r?\n\r?\n/, 2)
      header_lines = header_part.to_s.split(/\r?\n/)

      status_line = header_lines.shift
      version, status_code, status_message = parse_status_line(status_line)
      @version = Soren::Types::Response::Version.new(version) #: Soren::Types::Response::Version?
      @status_code = Soren::Types::Response::StatusCode.new(status_code) #: Soren::Types::Response::StatusCode?
      @status_message = Soren::Types::Response::StatusMessage.new(status_message) #: Soren::Types::Response::StatusMessage?

      parsed_headers = parse_headers(header_lines)
      @headers = Soren::Types::Response::Headers.new(parsed_headers) #: Soren::Types::Response::Headers?

      parsed_body = parse_body(body_part)
      @body = Soren::Types::Response::Body.new(parsed_body) #: Soren::Types::Response::Body?
    end

    #: (String?) -> [String, Integer, String]
    def parse_status_line(status_line)
      status_line_match = status_line&.match(%r{\A(HTTP/\d+\.\d+)\s+(\d{3})\s+(.+)\z})
      unless status_line_match
        raise Soren::Error::ArgumentError, 'invalid HTTP status line'
      end

      version = status_line_match[1]
      status_code_text = status_line_match[2]
      status_message = status_line_match[3]&.strip

      if version.blank? ||
         status_code_text.blank? ||
         status_message.blank?

        raise Soren::Error::ArgumentError, 'status line must include version, status_code and status_message'
      end

      [version, Integer(status_code_text), status_message]
    end

    #: (Array[String]) -> Hash[String, Array[String]]
    def parse_headers(header_lines)
      parsed_headers = {}
      header_lines.each do |line|
        next if line.blank?

        key, value = line.split(':', 2)
        unless key && value
          raise Soren::Error::ArgumentError, 'invalid HTTP header line'
        end

        normalized_key = key.strip.downcase
        parsed_headers[normalized_key] ||= []
        parsed_headers[normalized_key] << value.strip
      end

      parsed_headers
    end

    #: (String?) -> String
    def parse_body(body_part)
      body_part.to_s
    end
  end
end
