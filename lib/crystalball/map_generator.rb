# typed: true
# frozen_string_literal: true

module Crystalball
  # Class to generate execution map during RSpec build execution
  class MapGenerator
    extend T::Sig
    attr_reader :configuration

    delegate :map_storage, :strategies, :dump_threshold, :map_class, to: :configuration

    class << self
      extend T::Sig
      # Registers Crystalball handlers to generate execution map during specs execution
      #
      # @param [Proc] block to configure MapGenerator and Register strategies
      sig { params(block: T.untyped).returns(T.untyped) }
      def start!(&block)
        generator = new(&block)

        ::RSpec.configure do |c|
          c.before(:suite) { generator.start! }

          c.around(:each) { |e| generator.refresh_for_case(e) }

          c.after(:suite) { generator.finalize! }
        end
      end
    end

    sig { void }
    def initialize
      @configuration = Configuration.new
      @configuration.commit = T.must(repo).gcommit("HEAD") if repo
      yield @configuration if block_given?
    end

    # Registers strategies and prepares metadata for execution map
    sig { returns(T::Boolean) }
    def start!
      self.map = nil
      map_storage.clear!
      map_storage.dump(**map.metadata.to_h)

      strategies.reverse.each(&:after_start)
      self.started = true
    end

    # Runs example and collects execution map for it
    sig { params(example: T.untyped).void }
    def refresh_for_case(example)
      map << strategies.run(ExampleGroupMap.new(example), example) { example.run }
      check_dump_threshold
    end

    # Finalizes strategies and saves map
    sig { returns(T::Boolean) }
    def finalize!
      return false unless started

      strategies.each(&:before_finalize)

      return false unless map.size.positive?

      example_groups = (configuration.compact_map? ? MapCompactor.compact_map!(map) : map).example_groups
      map_storage.dump(example_groups)
    end

    sig { returns(Crystalball::ExecutionMap) }
    def map
      @map ||= map_class.new(metadata: { commit: configuration.commit&.sha, timestamp: configuration.commit&.date&.to_i,
                                         version: configuration.version })
    end

    private

    attr_writer :map

    sig { returns(T.nilable(T::Boolean)) }
    attr_accessor :started

    sig { returns(T.nilable(Crystalball::GitRepo)) }
    def repo
      @repo = GitRepo.open(".") unless defined?(@repo)
      @repo
    end

    sig { void }
    def check_dump_threshold
      return if configuration.compact_map
      return unless dump_threshold.positive? && map.size >= dump_threshold

      map_storage.dump(**map.example_groups)
      map.clear!
    end
  end
end
