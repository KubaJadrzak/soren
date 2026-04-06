# frozen_string_literal: true

require 'test_helper'
require 'uri'

class TestSoren < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Soren::VERSION
  end

  def test_new_accepts_explicit_host_port_and_scheme
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'https')

    assert_instance_of Soren::Connection, connection
  end

  def test_new_accepts_uri_object
    connection = Soren::Connection.new(uri: URI('https://example.com/test'))

    assert_instance_of Soren::Connection, connection
    assert_equal 'example.com', connection.instance_variable_get(:@host).to_s
    assert_equal 443, connection.instance_variable_get(:@port).to_i
    assert_equal 'https', connection.instance_variable_get(:@scheme).to_s
  end

  def test_new_rejects_uri_with_explicit_parts
    error = assert_raises(Soren::Error::ArgumentError) do
      Soren::Connection.new(uri: URI('https://example.com'), host: 'example.com', port: 443, scheme: 'https')
    end

    assert_equal 'pass either uri: or host:, port:, and scheme:, not both', error.message
  end

  def test_new_requires_complete_explicit_parts_without_uri
    error = assert_raises(Soren::Error::ArgumentError) do
      Soren::Connection.new(host: 'example.com', port: 443)
    end

    assert_equal 'host, port, and scheme are required when uri is not provided', error.message
  end
end
