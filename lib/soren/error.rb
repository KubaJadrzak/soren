# typed: strict
# frozen_string_literal: true

module Soren
  module Error
    class Base < StandardError; end
  end
end

require_relative 'error/argument_error'
require_relative 'error/response_error'
require_relative 'error/parser_error'
require_relative 'error/decoder_error'
require_relative 'error/connection_error'
require_relative 'error/timeout_error'
