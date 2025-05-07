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

      sig { returns(ExecutionDetector) }
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
      sig do
        params(
          example_map: T.any(T::Array[String], Crystalball::ExampleGroupMap),
          example: T.untyped,
        ).void
      end
      def call(example_map, example)
        before = Coverage.peek_result
        yield example_map, example
        after = Coverage.peek_result

        matched_examples = execution_detector.detect(before, after)
        matched_examples.each do |e|
          example_map.push(e)
        end
      end
    end
  end
end
