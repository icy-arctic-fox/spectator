require "../spec_helper"

module Readme
  abstract class Interface
    abstract def invoke(thing) : String
  end

  # Type being tested.
  class Driver
    def do_something(interface : Interface, thing)
      interface.invoke(thing)
    end
  end
end

Spectator.describe Readme::Driver do
  # Define a mock for Interface.
  mock Readme::Interface

  # Define a double that the interface will use.
  double(:my_double, foo: 42)

  it "does a thing" do
    # Create an instance of the mock interface.
    interface = mock(Readme::Interface)
    # Indicate that `#invoke` should return "test" when called.
    allow(interface).to receive(:invoke).and_return("test")

    # Create an instance of the double.
    dbl = double(:my_double)
    # Call the mock method.
    subject.do_something(interface, dbl)
    # Verify everything went okay.
    expect(interface).to have_received(:invoke).with(dbl)
  end
end
