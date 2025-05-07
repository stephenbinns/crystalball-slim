# typed: true
# frozen_string_literal: true

require "crystalball/map_generator/strategies_collection"

module Crystalball
  class MapGenerator
    # Configuration of map generator. Is can be accessed as a first argument inside
    # `Crystalball::MapGenerator.start! { |config| config } block.
    class Configuration
      extend T::Sig
      attr_writer :map_storage
      attr_writer :map_class
      attr_accessor :commit, :version, :compact_map

      attr_reader :strategies

      sig { void }
      def initialize
        @strategies = StrategiesCollection.new
        @compact_map = true
      end

      sig { returns(T::Boolean) }
      def compact_map?
        !!@compact_map
      end

      sig { returns(Class) }
      def map_class
        @map_class ||= ExecutionMap
      end

      sig { returns(Pathname) }
      def map_storage_path
        @map_storage_path ||= Pathname("tmp/crystalball_data.yml")
      end

      sig { params(value: String).returns(Pathname) }
      def map_storage_path=(value)
        @map_storage_path = Pathname(value)
      end

      sig { returns(Crystalball::MapStorage::YAMLStorage) }
      def map_storage
        @map_storage ||= MapStorage::YAMLStorage.new(map_storage_path)
      end

      sig { returns(Integer) }
      def dump_threshold
        @dump_threshold ||= 100
      end

      sig { params(value: T.any(String, Integer)).returns(Integer) }
      def dump_threshold=(value)
        @dump_threshold = value.to_i
      end

      # Register new strategy for map generation
      #
      # @param [Crystalball::MapGenerator::BaseStrategy] strategy
      sig { params(strategy: T.untyped).void }
      def register(strategy)
        @strategies.push strategy
        strategy.after_register
      end
    end
  end
end
