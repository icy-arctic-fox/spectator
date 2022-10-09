require "../spec_helper"

Spectator.describe "GitHub Issue #47" do
  class Original
    def foo(arg1, arg2)
      # ...
    end
  end

  mock Original

  let(fake) { mock(Original) }

  specify do
    expect(fake).to receive(:foo).with("arg1", arg2: "arg2")
    fake.foo("arg1", "arg2")
  end
end
