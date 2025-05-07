# typed: true
# frozen_string_literal: true

module Crystalball
  module MapCompactor
    # Class representing RSpec context data
    class ExampleContext
      extend T::Sig
      attr_reader :address

      sig { params(address: String).void }
      def initialize(address)
        @address = address
      end

      sig { returns(T.nilable(Crystalball::MapCompactor::ExampleContext)) }
      def parent
        @parent ||= begin
          parent_uid = address.split(":")[0..-2].join(":")
          parent_uid.empty? ? nil : self.class.new(parent_uid)
        end
      end

      sig { params(example_id: String).returns(T.nilable(Integer)) }
      def include?(example_id)
        example_id =~ /\[#{address}[\:\]]/
      end

      sig { returns(Integer) }
      def depth
        @depth ||= address.split(":").size
      end
    end
  end
end
