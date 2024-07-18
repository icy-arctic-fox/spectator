module Spectator::Formatters
  module CommonTextOutput
    def report_failures(results : Enumerable(Core::ExecutionResult)) : Nil
      puts "Failures:"
      puts
      padding = results.size.to_s.size - 1 # -1 since the minimum width is 1.
      results.each_with_index(1) do |result, index|
        print_failure(result, index, padding)
      end
    end

    # Produces a block of text that looks like this for failures:
    #
    # ```text
    # 1) Full example description
    #    Failure: "bar" did not equal "foo"
    #
    #    Expected: "foo"
    #         got: "bar"
    #
    #    # spec/example_spec.cr:42
    # ```
    #
    # and like this for errors:
    #
    # ```text
    # 1) Full example description
    #
    #    Error message (RuntimeError)
    #      <STACK TRACE>
    #
    #    # spec/example_spec.cr:42
    # ```
    private def print_failure(result, number, padding) : Nil
      print_indent(padding)
      print "  #{number}) "
      puts result.example.full_description

      digit_count = number.to_s.size
      indent = padding + digit_count + 4 # +2 for the space and the parenthesis and +2 for the actual indent.
      error = result.exception
      if error.is_a?(AssertionFailed)
        print_indent(indent)
        print "Failure: "
        puts error.message
        puts
        print_failure_fields(error.fields, indent) if error.fields.any?
        if location = error.location
          print_indent(indent)
          puts "# #{location}"
          puts
        end
      else
        puts
        print_trace(error, indent)
      end
      puts
    end

    private def print_failure_fields(fields, indent) : Nil
      max_name_length = fields.max_of do |field|
        if field.is_a?({Symbol, String}) || field.is_a?({String, String})
          field[0].to_s.size
        else
          0
        end
      end

      fields.each do |field|
        print_indent(indent)
        if field.is_a?({String | Symbol, String})
          name, value = field
          print name.to_s.rjust(max_name_length)
          print ": "
          puts value
        else # String
          puts field
        end
      end
    end

    private def print_trace(error, indent) : Nil
      print_indent(indent)
      puts "#{error.message} (#{error.class})"

      error.backtrace?.try &.each do |frame|
        print_indent(indent)
        print "  from "
        puts frame
      end

      if cause = error.cause
        print_trace(cause, indent)
      end
    end

    def report_pending(results : Enumerable(Core::ExecutionResult)) : Nil
    end

    private def print_pending(example : Core::Example) : Nil
    end

    def report_profile : Nil
    end

    def report_summary : Nil
    end

    def report_post_summary : Nil
    end

    private def print_indent(amount) : Nil
      amount.times { print ' ' }
    end
  end
end
