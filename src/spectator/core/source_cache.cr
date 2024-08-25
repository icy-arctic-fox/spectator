require "string_pool"
require "./sandbox"

module Spectator::Core
  # Caches the source code of a file.
  class SourceCache
    # Mapping of file paths to lines of source code.
    @cache = {} of String => Array(String)
    @pool = StringPool.new

    def get(path : String, line : Int) : String?
      with_file_cache(path) do |lines|
        lines[line - 1]?
      end
    end

    def get(path : String, line : Int, end_line : Int) : String?
      with_file_cache(path) do |lines|
        lines[line - 1, end_line - line + 1]?.try &.join
      end
    end

    private def with_file_cache(path : String, & : Array(String) -> _)
      if lines = @cache[path]?
        yield lines
      else
        lines = load_file(path)
        return unless lines
        @cache[path] = lines
        yield lines
      end
    end

    private def load_file(path : String) : Array(String)?
      return unless File.file?(path)

      lines = [] of String
      File.each_line(path, chomp: false) do |line|
        lines << @pool.get(line)
      end
      lines
    end
  end

  # Cache of source code for the current sandbox.
  Spectator.sandbox_getter source_cache = SourceCache.new
end
