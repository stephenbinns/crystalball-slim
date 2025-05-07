# typed: true
# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class ObjectSourcesDetector
      # Class to get full hierarchy of a module(including singleton_class)
      class HierarchyFetcher
        extend T::Sig
        attr_reader :stop_modules

        # @param [Array<String>] stop_modules - list of classes or modules which
        #   will be used to stop hierarchy lookup
        sig { params(stop_modules: T::Array[String]).void }
        def initialize(stop_modules = [])
          @stop_modules = stop_modules
        end

        # @param [Module] mod - the module for which to fetch the ancestors
        # @return [Array<Module>] list of ancestors of a module
        sig { params(mod: T.untyped).returns(T::Array[T.untyped]) }
        def ancestors_for(mod)
          (pick_ancestors(mod) + pick_ancestors(mod.singleton_class)).uniq
        end

        private

        sig { returns(T::Array[Class]) }
        def stop_consts
          @stop_consts ||= stop_modules.map { |str| Object.const_get(str) }
        end

        sig { params(mod: T.untyped).returns(T::Array[T.untyped]) }
        def pick_ancestors(mod)
          ancestors = mod.ancestors
          index = ancestors.index { |k| stop_consts.include?(k) } || ancestors.size
          ancestors[0...index]
        end
      end
    end
  end
end
