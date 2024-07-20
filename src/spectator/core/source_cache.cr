require "string_pool"
require "./sandbox"

module Spectator
  module Core
    # Caches the source code of a file.
    class SourceCache
      # Mapping of file paths to lines of source code.
      @cache = {} of String => Array(String)
      @pool = StringPool.new

      def get(path : String, line : Int) : String?
        lines = @cache[path]?
        unless lines
          return unless lines = load_file(path)
          @cache[path] = lines
        end
        lines[line - 1]?
      end

      private def load_file(path : String) : Array(String)?
        return unless File.file?(path)

        lines = [] of String
        File.each_line(path) do |line|
          lines << @pool.get(line)
        end
        lines
      end
    end

    class Sandbox
      getter source_cache = SourceCache.new
    end
  end

  def self.source_cache : Core::SourceCache
    sandbox.source_cache
  end
end
