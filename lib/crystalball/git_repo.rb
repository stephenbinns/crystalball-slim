# frozen_string_literal: true

require "git"

module Crystalball
  # Wrapper class representing Git repository
  class GitRepo
    attr_reader :repo_path

    class << self
      # @return [Crystalball::GitRepo] instance for given path
      def open(repo_path)
        path = Pathname(repo_path)
        new(path) if exists?(path)
      end

      # Check if given path is under git control (contains .git folder)
      def exists?(path)
        path.join(".git").directory?
      end
    end

    # @param [Pathname] repo_path path to repository root folder
    def initialize(repo_path)
      @repo_path = repo_path
    end

    # Proxy all unknown calls to `Git` object
    def method_missing(method, *args, &block)
      repo.public_send(method, *args, &block)
    end

    def respond_to_missing?(method, *)
      repo.respond_to?(method, false)
    end

    private

    def repo
      @repo ||= Git.open(repo_path)
    end
  end
end
