# typed: true
# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class ObjectSourcesDetector
      # Class to save paths to classes and modules definitions during code loading. Should be
      # started as soon as possible. Use #constants_definition_paths to fetch traced info
      class DefinitionTracer
        extend T::Sig
        attr_reader :trace_point, :constants_definition_paths, :root_path

        sig { params(root_path: String).void }
        def initialize(root_path)
          @root_path = root_path
          @constants_definition_paths = {}
        end

        sig { returns(TracePoint) }
        def start
          self.trace_point ||= TracePoint.new(:class) do |tp|
            mod = tp.self
            path = T.let(tp.path, T.nilable(String))

            next unless path&.start_with?(root_path)

            constants_definition_paths[mod] ||= []
            constants_definition_paths[mod] << path
          end.tap(&:enable)
        end

        sig { void }
        def stop
          trace_point&.disable
          self.trace_point = nil
        end

        private

        attr_writer :trace_point, :constants_definition_paths
      end
    end
  end
end
