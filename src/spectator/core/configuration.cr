require "../formatters/*"
require "./hooks"
require "./sandbox"

module Spectator
  module Core
    class Configuration
      include Hooks

      enum Order
        Defined
        Random
        RecentlyModified
      end

      DEFAULT_FAIL_FAST_EXAMPLES =  1
      DEFAULT_SLOWEST_EXAMPLES   = 10

      property formatters do
        [Formatters::DotsFormatter.new] of Formatters::Formatter
      end

      def add_formatter(formatter : Formatters::Formatter) : Nil
        formatters << formatter
      end

      def formatter=(formatter : Formatters::Formatter)
        self.formatters = [formatter] of Formatters::Formatter
        formatter
      end

      property? dry_run = false

      property fail_fast = 1

      def fail_fast? : Bool
        @fail_fast > 0
      end

      def fail_fast=(flag : Bool)
        @fail_fast = flag ? DEFAULT_FAIL_FAST_EXAMPLES : 0
      end

      property? fail_if_no_examples = true

      property profile_examples = 0

      def profile_examples? : Bool
        @profile_examples > 0
      end

      def profile_examples=(flag : Bool)
        @profile_examples = flag ? DEFAULT_SLOWEST_EXAMPLES : 0
      end

      property order = Order::Defined

      property! seed : UInt64

      property error_exit_code = 1
    end

    class Sandbox
      getter configuration = Configuration.new
    end
  end

  def self.configuration
    sandbox.configuration
  end

  def self.configure(& : Core::Configuration ->) : Core::Configuration
    yield configuration
    configuration
  end
end
