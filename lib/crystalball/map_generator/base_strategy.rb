# typed: true
# frozen_string_literal: true

module Crystalball
  class MapGenerator
    # Map generator strategy interface
    module BaseStrategy
      extend T::Sig
      def after_register; end

      def after_start; end

      def before_finalize; end

      # Each strategy must implement #call augmenting the used_files list and
      # yielding back the ExampleGroupMap.
      # @param [Crystalball::ExampleGroupMap] _example_map - object holding example metadata and used files
      # @param [RSpec::Core::Example] _example - a RSpec example
      sig { params(_example_map: T.untyped, _example: T.untyped).void }
      def call(_example_map, _example)
        Kernel.raise NotImplementedError
      end
    end
  end
end
