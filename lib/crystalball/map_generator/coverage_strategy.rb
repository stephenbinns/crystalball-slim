# typed: true
# frozen_string_literal: true

require "coverage"
require "crystalball/map_generator/base_strategy"
require "crystalball/map_generator/coverage_strategy/execution_detector"

module Crystalball
  class MapGenerator
    # Map generator strategy based on harvesting Coverage information during example execution
    class CoverageStrategy
      extend T::Sig
      include BaseStrategy

      attr_reader :execution_detector

      sig { params(execution_detector: ExecutionDetector).void }
      def initialize(execution_detector = ExecutionDetector.new)
        @execution_detector = execution_detector
      end

      sig { void }
      def after_register
        Coverage.start unless Coverage.running?
      end

      # Adds to the example_map's used files the ones the ones in which
      # the coverage has changed after the tests runs.
      # @param [Crystalball::ExampleGroupMap] example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] example - a RSpec example
      sig { params(example_map: T::Array[T.untyped], example: String).returns(T::Array[T.untyped]) }
      def call(example_map, example)
        before = Coverage.peek_result
        yield example_map, example
        after = Coverage.peek_result
        example_map.push(*execution_detector.detect(before, after))
      end
    end
  end
end
