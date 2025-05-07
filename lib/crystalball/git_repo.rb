# typed: true
# frozen_string_literal: true

require "git"

module Crystalball
  # Wrapper class representing Git repository
  class GitRepo
    extend T::Sig

    attr_reader :repo_path

    class << self
      extend T::Sig

      # @return [Crystalball::GitRepo] instance for given path
      sig { params(repo_path: String).returns(T.nilable(Crystalball::GitRepo)) }
      def open(repo_path)
        path = Pathname(repo_path)
        new(path) if exists?(path)
      end

      # Check if given path is under git control (contains .git folder)
      sig { params(path: Pathname).returns(T::Boolean) }
      def exists?(path)
        path.join(".git").directory?
      end
    end

    # @param [Pathname] repo_path path to repository root folder
    sig { params(repo_path: Pathname).void }
    def initialize(repo_path)
      @repo_path = repo_path
    end

    sig { params(ref: String).returns(T.untyped) }
    def gcommit(ref)
      repo.gcommit(ref)
    end

    private

    sig { returns(Git::Base) }
    def repo
      @repo ||= Git.open(repo_path)
    end
  end
end
