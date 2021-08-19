require "./formatter"

module Spectator::Formatting
  # Reports events to multiple other formatters.
  # Events received by this formatter will be sent to others.
  class BroadcastFormatter < Formatter
    # Creates the broadcast formatter.
    # Takes a collection of formatters to pass events along to.
    def initialize(@formatters : Enumerable(Formatter))
    end

    # Forwards the event to other formatters.
    def start(notification)
      @formatters.each(&.start(notification))
    end

    # :ditto:
    def example_started(notification)
      @formatters.each(&.example_started(notification))
    end

    # :ditto:
    def example_finished(notification)
      @formatters.each(&.example_finished(notification))
    end

    # :ditto:
    def example_passed(notification)
      @formatters.each(&.example_passed(notification))
    end

    # :ditto:
    def example_pending(notification)
      @formatters.each(&.example_pending(notification))
    end

    # :ditto:
    def example_failed(notification)
      @formatters.each(&.example_failed(notification))
    end

    # :ditto:
    def example_error(notification)
      @formatters.each(&.example_error(notification))
    end

    # :ditto:
    def message(notification)
      @formatters.each(&.message(notification))
    end

    # :ditto:
    def stop
      @formatters.each(&.stop)
    end

    # :ditto:
    def start_dump
      @formatters.each(&.start_dump)
    end

    # :ditto:
    def dump_pending(notification)
      @formatters.each(&.dump_pending(notification))
    end

    # :ditto:
    def dump_failures(notification)
      @formatters.each(&.dump_failures(notification))
    end

    # :ditto:
    def dump_summary(notification)
      @formatters.each(&.dump_summary(notification))
    end

    # :ditto:
    def dump_profile(notification)
      @formatters.each(&.dump_profile(notification))
    end

    # :ditto:
    def close
      @formatters.each(&.close)
    end
  end
end
