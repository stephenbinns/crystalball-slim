# typed: true
# frozen_string_literal: true

module Crystalball
  # Storage for execution map
  class ExecutionMap
    extend T::Sig

    # Simple data object for map metadata information
    class Metadata
      extend T::Sig
      attr_reader :commit, :type, :version, :timestamp

      # @param [String] commit - SHA of commit
      # @param [String] type - type of execution map
      # @param [Numeric] version - map generator version number
      sig { params(commit: T.nilable(String), type: T.nilable(String), version: T.nilable(Float), timestamp: T.nilable(Integer)).void }
      def initialize(commit: nil, type: nil, version: nil, timestamp: nil)
        @commit = commit
        @type = type
        @timestamp = timestamp
        @version = version
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def to_h
        { type: type, commit: commit, timestamp: timestamp, version: version }
      end
    end

    sig { returns(T::Hash[String, T::Array[T.untyped]]) }
    attr_reader :example_groups

    sig { returns(Metadata) }
    attr_reader :metadata

    delegate :commit, :version, :timestamp, to: :metadata
    delegate :size, to: :example_groups

    # @param [Hash] metadata - add or override metadata of execution map
    # @param [Hash] example_groups - initial list of example groups data
    sig { params(metadata: T::Hash[Symbol, String], example_groups: T::Hash[String, T::Array[String]]).void }
    def initialize(metadata: {}, example_groups: {})
      @example_groups = example_groups

      @metadata = Metadata.new(type: self.class.name, **metadata)
    end

    # Adds example group map to the list
    #
    # @param [Crystalball::ExampleGroupMap] example_group_map
    sig { params(example_group_map: Crystalball::ExampleGroupMap).void }
    def <<(example_group_map)
      example_groups[example_group_map.uid] = example_group_map.used_files.uniq
    end

    # Remove all example_groups
    sig { void }
    def clear!
      self.example_groups = {}
    end

    private

    attr_writer :example_groups, :metadata
  end
end
