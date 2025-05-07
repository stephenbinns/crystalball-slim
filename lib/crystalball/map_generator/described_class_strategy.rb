# typed: true
# frozen_string_literal: true

require "crystalball/map_generator/base_strategy"
require "crystalball/map_generator/object_sources_detector"

module Crystalball
  class MapGenerator
    # Map generator strategy to get paths to files contains definition of described_class and its
    # ancestors.
    class DescribedClassStrategy
      extend T::Sig
      include BaseStrategy

      sig { returns(ObjectSourcesDetector) }
      attr_reader :execution_detector

      delegate :after_register, :before_finalize, to: :execution_detector

      # @param [#detect] execution_detector - object that, given a list of objects,
      #   returns the paths where the classes or modules of the list are defined
      sig { params(execution_detector: ObjectSourcesDetector).void }
      def initialize(execution_detector: ObjectSourcesDetector.new(root_path: Dir.pwd))
        @execution_detector = execution_detector
      end

      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      sig do
        params(
          example_map: T.any(T::Array[String], Crystalball::ExampleGroupMap),
          example: T.untyped,
        ).void
      end
      def call(example_map, example)
        yield example_map, example

        described_class = example.metadata[:described_class]

        if described_class
          matched_examples = execution_detector.detect([described_class])
          matched_examples.each do |e|
            example_map.push(e)
          end
        end
      end
    end
  end
end
