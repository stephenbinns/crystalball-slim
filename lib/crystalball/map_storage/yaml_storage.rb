# typed: true
# frozen_string_literal: true

require "yaml"

module Crystalball
  class MapStorage
    # Exception class for missing map files
    class NoFilesFoundError < StandardError; end

    # YAML persistence adapter for execution map storage
    class YAMLStorage
      extend T::Sig
      attr_reader :path

      class << self
        extend T::Sig
        # Loads map from given path
        #
        # @param [String] path to map
        # @return [Crystalball::ExecutionMap]
        sig { params(path: Pathname).returns(Crystalball::ExecutionMap) }
        def load(path)
          meta, example_groups = *read_files(path).transpose

          guard_metadata_consistency(T.must(meta))

          metadata = T.must(T.must(meta).first)
          type = metadata.fetch(:type)

          Object.const_get(type).new(
            metadata: metadata,
            example_groups: T.must(example_groups).compact.inject(&:merge!),
          )
        end

        private

        sig { params(path: Pathname).returns(T::Array[T::Array[T::Hash[Symbol, T.untyped]]]) }
        def read_files(path)
          paths = path.directory? ? path.children.select(&:file?) : [path]

          raise NoFilesFoundError, "No files or folder exists #{path}" unless paths.any?(&:exist?)

          paths.map do |file|
            metadata, *example_groups = file.read.split("---\n").reject(&:empty?).map do |yaml|
              YAML.safe_load(yaml, permitted_classes: [Symbol])
            end
            example_groups = example_groups.inject(&:merge!)

            [metadata, example_groups]
          end
        end

        sig { params(metadata: T::Array[T::Hash[T.untyped, T.untyped]]).returns(T.untyped) }
        def guard_metadata_consistency(metadata)
          uniq = metadata.uniq
          raise "Can't load execution maps with different metadata. Metadata: #{uniq}" if uniq.size > 1
        end
      end

      # @param [String] path to store execution map
      sig { params(path: Pathname).void }
      def initialize(path)
        @path = path
      end

      # Removes storage file
      sig { void }
      def clear!
        path.delete if path.exist?
      end

      # Writes data to storage file
      #
      # @param [Hash] data to write to storage file
      sig { params(data: T::Hash[String, String]).returns(T.untyped) }
      def dump(data)
        path.dirname.mkpath
        path.open("a") { |f| f.write YAML.dump(data) }
      end
    end
  end
end
