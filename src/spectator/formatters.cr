require "./core/configuration"
require "./formatters/**"

module Spectator
  module Formatters
  end

  module Core
    class Configuration
      # List of formatters to use.
      # By default, `Formatters::DotsFormatter` is used.
      property formatters do
        [Formatters::DotsFormatter.new] of Formatters::Formatter
      end

      # Add a formatter to the list of formatters.
      def add_formatter(formatter : Formatters::Formatter) : Nil
        formatters << formatter
      end

      # Sets the only formatter to use.
      # Any formatters previously set will be discarded.
      def formatter=(formatter : Formatters::Formatter)
        self.formatters = [formatter] of Formatters::Formatter
        formatter
      end
    end
  end
end
