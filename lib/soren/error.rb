# typed: strict
# frozen_string_literal: true

module Soren
  module Error
    class Base < StandardError; end
  end
end

require_relative 'error/argument_error'
require_relative 'error/connection_error'
require_relative 'error/timeout_error'
require_relative 'error/dns_failure'
require_relative 'error/connection_refused'
require_relative 'error/ssl_error'
require_relative 'error/read_error'
require_relative 'error/parse_error'
require_relative 'error/protocol_error'
