require "./test_case"

module Spectator::Formatting::Components::JUnit
  # Test suite node of the JUnit XML document.
  # This is the "testsuite" element and all of its children.
  struct TestSuite
    # Amounts for each type of test result.
    record Counts, total : Int32, failures : Int32, errors : Int32, skipped : Int32

    # Creates the test suite element.
    def initialize(@package : String, @name : String, @cases : Array(TestCase),
                   @time : Time::Span, @counts : Counts, @hostname : String)
    end

    # Constructs the test suite element from a collection of tests.
    # The *examples* should all come from the same *file*.
    def self.from_examples(file, examples, hostname)
      package, name = package_name_from_file(file)
      counts = count_examples(examples)
      time = examples.sum(&.result.elapsed)
      cases = examples.map { |example| TestCase.new(name, example) }
      new(package, name, cases, time, counts, hostname)
    end

    # Constructs a package and suite name from a file path.
    private def self.package_name_from_file(file)
      path = Path.new(file.to_s)
      name = path.stem
      directory = path.dirname
      package = directory.gsub(File::SEPARATOR, '.')
      {package, name}
    end

    # Counts the number of examples for each result type.
    private def self.count_examples(examples)
      visitor = CountVisitor.new

      # Iterate through each example and count the number of each type of result.
      # Don't count examples that haven't run (indicated by `Node#finished?`).
      # This typically happens in fail-fast mode.
      examples.each do |example|
        example.result.accept(visitor) if example.finished?
      end

      visitor.counts
    end

    # Produces the XML fragment.
    def to_xml(xml)
      xml.element("testsuite",
        package: @package,
        name: @name,
        tests: @counts.total,
        failures: @counts.failures,
        errors: @counts.errors,
        skipped: @counts.skipped,
        time: @time.total_seconds,
        hostname: @hostname) do
        @cases.each(&.to_xml(xml))
      end
    end

    # Totals up the number of each type of result.
    # Defines methods for the different types of results.
    # Call `#counts` to retrieve the `Counts` instance.
    private class CountVisitor
      @pass = 0
      @failures = 0
      @errors = 0
      @skipped = 0

      # Increments the number of passing examples.
      def pass(_result)
        @pass += 1
      end

      # Increments the number of failing (non-error) examples.
      def fail(_result)
        @failures += 1
      end

      # Increments the number of error (and failed) examples.
      def error(result)
        fail(result)
        @errors += 1
      end

      # Increments the number of pending (skipped) examples.
      def pending(_result)
        @skipped += 1
      end

      # Produces the total counts.
      def counts
        Counts.new(
          total: @pass + @failures + @skipped,
          failures: @failures,
          errors: @errors,
          skipped: @skipped
        )
      end
    end
  end
end
