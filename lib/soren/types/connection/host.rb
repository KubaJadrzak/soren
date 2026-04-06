# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Connection
      class Host
        #: (untyped) -> void
        def initialize(host)
          @host = validate(host) #: String
        end

        #: -> String
        def to_s
          @host
        end

        private

        #: (untyped) -> String
        def validate(host)
          unless host.is_a?(String) && !host.blank?
            raise Soren::Error::ArgumentError, 'host must be a non-empty String'
          end

          raise Soren::Error::ArgumentError, 'invalid host' unless host =~ /\A[a-z0-9\-\.]+\z/i ||
                                                                   host =~ Resolv::IPv4::Regex ||
                                                                   host =~ Resolv::IPv6::Regex


          raise Soren::Error::ArgumentError, 'host not resolvable' unless resolvable?(host)

          host
        end

        #: (String) -> bool
        def resolvable?(host)
          begin
            Resolv.getaddress(host)
            true
          rescue Resolv::ResolvError
            false
          end
        end
      end
    end
  end
end
