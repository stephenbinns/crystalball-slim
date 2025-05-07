# typed: true
# frozen_string_literal: true

module Crystalball
  class MapGenerator
    module Helpers
      # Helper module to filter file paths
      module PathFilter
        extend T::Sig
        attr_reader :root_path

        # @param [String] root_path - absolute path to root folder of repository
        sig { params(root_path: String).void }
        def initialize(root_path = Dir.pwd)
          @root_path = root_path
        end

        # @param [Array<String>] paths
        # @return relatve paths inside root_path only
        sig { params(paths: T::Array[String]).returns(T::Array[String]) }
        def filter(paths)
          paths.
            select { |file_name| file_name.start_with?(root_path) }.
            map { |file_name| file_name.sub("#{root_path}/", "") }
        end
      end
    end
  end
end
