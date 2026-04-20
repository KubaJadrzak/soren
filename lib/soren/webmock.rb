# typed: ignore
# frozen_string_literal: true

require 'webmock'
require_relative 'connection'
require_relative 'response'

module SorenWebMockHook
  def send(request)
    return super unless request.is_a?(Soren::Request)

    uri = "#{instance_variable_get(:@scheme)}://#{instance_variable_get(:@host)}:" \
          "#{instance_variable_get(:@port)}#{request.target}"

    sig = WebMock::RequestSignature.new(
      request.method.to_s.downcase.to_sym,
      uri,
      body:    request.body.to_s,
      headers: request.headers.to_h,
    )

    WebMock::RequestRegistry.instance.requested_signatures.put(sig)

    if (webmock_response = WebMock::StubRegistry.instance.response_for_request(sig))
      webmock_response.raise_error_if_any
      raise Soren::Error::TimeoutError, 'connection timeout' if webmock_response.should_timeout

      if WebMock::CallbackRegistry.any_callbacks?
        WebMock::CallbackRegistry.invoke_callbacks({ lib: :soren }, sig, webmock_response)
      end

      build_soren_response(webmock_response)
    elsif WebMock.net_connect_allowed?(sig.uri)
      response = super

      if WebMock::CallbackRegistry.any_callbacks?
        wm = WebMock::Response.new
        wm.status = [response.code, response.message]
        wm.headers = response.headers
        wm.body = response.body
        WebMock::CallbackRegistry.invoke_callbacks({ lib: :soren, real_request: true }, sig, wm)
      end

      response
    else
      raise WebMock::NetConnectNotAllowedError, sig
    end
  end

  private

  def build_soren_response(webmock_response)
    raw_headers = webmock_response.headers || {}
    headers = raw_headers.each_with_object({}) do |(k, v), h|
      h[k.to_s] = Array(v).map(&:to_s)
    end

    Soren::Response.from_parts(
      code:    webmock_response.status[0],
      message: webmock_response.status[1].to_s,
      version: '1.1',
      headers: headers,
      body:    webmock_response.body.to_s,
    )
  end
end

module WebMock
  module HttpLibAdapters
    class SorenAdapter < HttpLibAdapter
      adapter_for :soren

      class << self
        def enable!
          return if ::Soren::Connection.ancestors.include?(SorenWebMockHook)

          ::Soren::Connection.prepend(SorenWebMockHook)
        end

        def disable!; end
      end
    end
  end
end
