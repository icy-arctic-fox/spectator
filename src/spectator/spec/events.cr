module Spectator
  class Spec
    # Mix-in for announcing events from a `Runner`.
    # All events invoke their corresponding method on the formatter.
    module Events
      # Triggers the 'start' event.
      # See `Formatting::Formatter#start`
      private def start
        notification = Formatting::StartNotification.new(example_count)
        formatter.start(notification)
      end

      # Triggers the 'example started' event.
      # Must be passed the *example* about to run.
      # See `Formatting::Formatter#example_started`
      private def example_started(example)
        notification = Formatting::ExampleNotification.new(example)
        formatter.example_started(notification)
      end

      # Triggers the 'example started' event.
      # Also triggers the example result event corresponding to the example's outcome.
      # Must be passed the completed *example*.
      # See `Formatting::Formatter#example_finished`
      private def example_finished(example)
        notification = Formatting::ExampleNotification.new(example)
        formatter.example_started(notification)

        case example.result
        when .fail? then formatter.example_failed(notification)
        when .pass? then formatter.example_passed(notification)
        else formatter.example_pending(notification)
        end
      end

      # Triggers the 'stop' event.
      # See `Formatting::Formatter#stop`
      private def stop
        formatter.stop(nil)
      end

      # Triggers the 'close' event.
      # See `Formatting::Formatter#close`
      private def close
        formatter.close(nil)
      end
    end
  end
end
