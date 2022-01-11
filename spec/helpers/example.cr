require "ecr"
require "json"
require "./result"

module Spectator::SpecHelpers
  # Wrapper for compiling and running an example at runtime and getting a result.
  class Example
    # Creates the example.
    # The *spec_helper_path* is the path to spec_helper.cr file.
    # The name or ID of the example is given by *example_id*.
    # Lastly, the source code for the example is given by *example_code*.
    def initialize(@spec_helper_path : String, @example_id : String, @example_code : String)
    end

    # Instructs the Crystal compiler to compile the test.
    # Returns an instance of `JSON::Any`.
    # This will be the outcome and information about the test.
    # Output will be suppressed for the test.
    # If an error occurs while attempting to compile and run the test, an error will be raised.
    def compile
      # Create a temporary file containing the test.
      with_tempfile do |source_file|
        args = ["run", "--no-color", source_file, "--", "--json"]
        Process.run(crystal_executable, args) do |process|
          JSON.parse(process.output)
        rescue JSON::ParseException
          raise "Compilation of example #{@example_id} failed\n\n#{process.error.gets_to_end}"
        end
      end
    end

    # Same as `#compile`, but returns the result of the first example in the test.
    # Returns a `SpectatorHelpers::Result` instance.
    def result
      output = compile
      example = output["examples"][0]
      Result.from_json_any(example)
    end

    # Constructs the string representation of the example.
    # This produces the Crystal source code.
    # *io* is the file handle to write to.
    # The *dir* is the directory of the file being written to.
    # This is needed to resolve the relative path to the spec_helper.cr file.
    private def write(io, dir)
      spec_helper_path = Path[@spec_helper_path].relative_to(dir) # ameba:disable Lint/UselessAssign
      ECR.embed(__DIR__ + "/example.ecr", io)
    end

    # Creates a temporary file containing the compilable example code.
    # Yields the path of the temporary file.
    # Ensures the file is deleted after it is done being used.
    private def with_tempfile
      tempfile = File.tempfile("_#{@example_id}_spec.cr") do |file|
        dir = File.dirname(file.path)
        write(file, dir)
      end

      begin
        yield tempfile.path
      ensure
        tempfile.delete
      end
    end

    # Attempts to find the Crystal compiler on the system or raises an error.
    private def crystal_executable
      Process.find_executable("crystal") || raise("Could not find Crystal compiler")
    end
  end
end
