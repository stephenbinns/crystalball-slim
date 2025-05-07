# typed: false
# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Manages map generation strategies
    class StrategiesCollection
      extend T::Sig
      sig { params(strategies: T::Array[T.untyped]).void }
      def initialize(strategies = [])
        @strategies = strategies
      end

      # Calls every strategy on the given example group map and returns the modified example group map
      # @param [Crystalball::ExampleGroupMap] example_group_map - initial example group map
      # @return [Crystalball::ExampleGroupMap] example group map augmented by each strategy
      sig do
        params(example_group_map: T.untyped, example: T.any(String, T.untyped),
               block: T.nilable(Proc)).returns(T.any(T::Array[String], Crystalball::ExampleGroupMap))
      end
      def run(example_group_map, example, &block)
        run_for_strategies(example_group_map, example, _strategies.reverse, &block)
        example_group_map
      end

      delegate :push, :reverse, :each, :empty?, :to_a, to: :_strategies

      def method_missing(method_name, *args, &block)
        puts "!!!!! #{method_name}"
        _strategies.public_send(method_name, *args, &block) || super
      end

      def respond_to_missing?(method_name, *_args)
        _strategies.respond_to?(method_name, false) || super
      end

      private

      sig { returns(T::Array[BaseStrategy]) }
      def _strategies
        @strategies
      end

      sig do
        params(
          example_group_map: T.any(T::Array[String], Crystalball::ExampleGroupMap),
          example: T.untyped,
          strats: T::Array[T.untyped],
          block: Proc,
        ).void
      end
      def run_for_strategies(example_group_map, example, strats, &block)
        return yield(example_group_map) if strats.empty?

        strat = strats.shift
        strat.call(example_group_map, example) { |c| run_for_strategies(c, example, strats, &block) }
      end
    end
  end
end
