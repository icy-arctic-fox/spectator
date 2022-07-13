require "../spec_helper"

private abstract class Interface
  abstract def invoke(thing) : String
end

# Type being tested.
private class Driver
  def do_something(interface : Interface, thing)
    interface.invoke(thing)
  end
end

Spectator.describe Driver do
  # Define a mock for Interface.
  mock Interface

  # Define a double that the interface will use.
  double(:my_double, foo: 42)

  it "does a thing" do
    # Create an instance of the mock interface.
    interface = mock(Interface)
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
