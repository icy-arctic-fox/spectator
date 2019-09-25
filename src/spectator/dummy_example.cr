require "./runnable_example"

module Spectator
  # Example that does nothing.
  # This is to workaround a Crystal compiler bug.
  # See: [Issue 4225](https://github.com/crystal-lang/crystal/issues/4225)
  # If there are no concrete implementations of an abstract class,
  # the compiler gives an error.
  # The error indicates an abstract method is undefined.
  # This class shouldn't be used, it's just to trick the compiler.
  private class DummyExample < RunnableExample
    # Dummy description.
    def what : Symbol | String
      "DUMMY"
    end

    # Dummy symbolic flag.
    def symbolic? : Bool
      false
    end

    # Dummy source.
    def source : Source
      Source.new(__FILE__, __LINE__)
    end

    # Dummy instance.
    def instance
      nil
    end

    # Dummy run that does nothing.
    def run_instance
      raise "You shouldn't be running this."
    end
  end
end
