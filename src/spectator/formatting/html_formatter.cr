require "ecr"
require "html"
require "./formatter"

module Spectator::Formatting
  # Produces an HTML document with results of the test suite.
  class HTMLFormatter < Formatter
    # Default HTML file name.
    private OUTPUT_FILE = "output.html"

    # Output stream for the HTML file.
    private getter! io : IO

    # Creates the formatter.
    # The *output_path* can be a directory or path of an HTML file.
    # If the former, then an "output.html" file will be generated in the specified directory.
    def initialize(output_path = OUTPUT_FILE)
      @output_path = if output_path.ends_with?(".html")
                       output_path
                     else
                       File.join(output_path, OUTPUT_FILE)
                     end
    end

    # Prepares the formatter for writing.
    def start(_notification)
      @io = File.open(@output_path, "w")
      ECR.embed(__DIR__ + "/html/head.ecr", io)
    end

    # Invoked after testing completes with summarized information from the test suite.
    # All results are gathered at the end, then the report is generated.
    def dump_summary(notification)
      report = notification.report # ameba:disable Lint/UselessAssign
      ECR.embed(__DIR__ + "/html/body.ecr", io)
    end

    # Invoked at the end of the program.
    # Allows the formatter to perform any cleanup and teardown.
    def close
      ECR.embed(__DIR__ + "/html/foot.ecr", io)
      io.flush
      io.close
    end

    private def escape(string)
      HTML.escape(string.to_s, io)
    end

    private def runtime(span)
      Components::Runtime.new(span).to_s
    end

    private def totals(report)
      Components::Totals.new(report.counts)
    end

    private def summary_result(report)
      counts = report.counts
      if counts.fail > 0
        "fail"
      elsif counts.pending > 0
        "pending"
      else
        "pass"
      end
    end
  end
end
