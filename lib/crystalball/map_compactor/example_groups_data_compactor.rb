# typed: true
# frozen_string_literal: true

require "crystalball/map_compactor/example_context"

module Crystalball
  module MapCompactor
    # Class representing example groups data compacting logic for a single file
    class ExampleGroupsDataCompactor
      extend T::Sig
      # @param [Hash] plain_data a hash of examples and used files
      sig { params(plain_data: T::Hash[String, T::Array[Integer]]).returns(T::Hash[String, T::Array[Integer]]) }
      def self.compact!(plain_data)
        new(plain_data).compact!
      end

      sig { returns(T::Hash[String, T::Array[Integer]]) }
      def compact!
        contexts = extract_contexts(plain_data.keys).sort_by(&:depth)

        contexts.each do |context|
          compact_data[context.address] = compact_context!(context)
        end
        compact_data
      end

      private

      attr_reader :compact_data, :plain_data

      sig { params(plain_data: T::Hash[String, T::Array[Integer]]).void }
      def initialize(plain_data)
        @plain_data = plain_data
        @compact_data = {}
      end

      sig { params(context: Crystalball::MapCompactor::ExampleContext).returns(T.any(String, T::Array[Integer])) }
      def compact_context!(context)
        result = T.let(nil, T.untyped)
        plain_data.each do |example_uid, used_files|
          next unless context.include?(example_uid)

          if result.nil?
            result = used_files
            result -= deep_used_files(T.must(context.parent)) if context.parent
          else
            result &= used_files
          end
        end
        result
      end

      sig { params(context: Crystalball::MapCompactor::ExampleContext).returns(T::Array[Integer]) }
      def deep_used_files(context)
        result = compact_data[context.address]
        result += deep_used_files(T.must(context.parent)) if context.parent
        result
      end

      sig { params(example_uids: T::Array[String]).returns(T::Array[Crystalball::MapCompactor::ExampleContext]) }
      def extract_contexts(example_uids)
        result = []
        example_uids.each do |example_uid|
          matches = /\[(.*)\]/.match(example_uid)
          context_numbers = T.must(T.must(matches)[1]&.split(":"))

          until context_numbers.empty?
            result << ExampleContext.new(context_numbers.join(":"))
            context_numbers.pop
          end
        end
        result.compact.uniq(&:address)
      end
    end
  end
end
