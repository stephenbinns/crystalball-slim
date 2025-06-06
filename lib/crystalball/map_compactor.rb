# typed: true
# frozen_string_literal: true

require "ostruct"

require "crystalball/example_group_map"
require "crystalball/execution_map"
require "crystalball/map_compactor/example_groups_data_compactor"

module Crystalball
  # a module for compacting execution map by moving out repeated used files to upper contexts records.
  module MapCompactor
    class << self
      extend T::Sig
      # @param [Crystalball::ExecutionMap] map execution map to be compacted
      # @return [Crystalball::ExecutionMap] compact map
      sig { params(map: Crystalball::ExecutionMap).returns(Crystalball::ExecutionMap) }
      def compact_map!(map)
        new_map = Crystalball::ExecutionMap.new(metadata: map.metadata.to_h)

        compact_examples!(map.example_groups).each do |context, used_files|
          new_map << ExampleGroupMap.new(OpenStruct.new(id: context, file_path: example_filename(context)), used_files)
        end

        new_map
      end

      sig { params(example_groups: T::Hash[String, T.untyped]).returns(T::Hash[String, T::Array[String]]) }
      def compact_examples!(example_groups)
        result = {}
        example_groups.group_by { |k, _v| example_filename(k) }.each do |filename, examples|
          compact_data = ExampleGroupsDataCompactor.compact!(examples.to_h)

          compact_data.each do |context_address, used_files|
            result["#{filename}[#{context_address}]"] = used_files unless used_files.empty?
          end
        end
        result
      end

      private

      sig { params(example_id: String).returns(String) }
      def example_filename(example_id)
        T.must(example_id.split("[").first)
      end
    end
  end
end
