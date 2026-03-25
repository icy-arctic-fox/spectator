require "./formatter"

module Spectator::Formatting
  # Writes failed example locations to a file after each run.
  class ExampleStatusPersistence < Formatter
    FILE_PATH = ".spectator-failures"

    def dump_summary(notification)
      File.open(FILE_PATH, "w") do |file|
        notification.report.failures.each do |example|
          next unless location = example.location?
          file.puts location
        end
      end
    rescue
    end
  end
end
