require "../spec_helper"

Spectator.describe "GitHub Issue #28" do
  class Test
    def foo
      42
    end
  end

  mock Test do
    stub foo
  end

  it "matches method stubs with no_args" do
    test = Test.new
    expect(test).to receive(:foo).with(no_args).and_return(42)
    test.foo
  end
end
