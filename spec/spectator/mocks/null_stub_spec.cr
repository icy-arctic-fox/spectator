require "../../spec_helper"

Spectator.describe Spectator::NullStub do
  let(method_call) { Spectator::MethodCall.capture(:foo) }
  subject(stub) { described_class.new(:foo) }

  it "stores the method name" do
    expect(stub.method).to eq(:foo)
  end

  it "returns nil" do
    expect(stub.call(method_call)).to be_nil
  end

  context Spectator::StubModifiers do
    describe "#and_return(value)" do
      let(arguments) { Spectator::Arguments.capture(/foo/) }
      let(original) { Spectator::NullStub.new(:foo, arguments) }
      subject(stub) { original.and_return(42) }

      it "produces a stub that returns a value" do
        expect(stub.call(method_call)).to eq(42)
      end

      it "retains the method name" do
        expect(stub.method).to eq(:foo)
      end

      it "retains the arguments constraint" do
        expect(stub.constraint).to eq(arguments)
      end
    end
  end

  describe "#===" do
    subject { stub === call }

    context "with a matching method name" do
      let(call) { Spectator::MethodCall.capture(:foo, "foobar") }

      it "returns true" do
        is_expected.to be_true
      end
    end

    context "with a different method name" do
      let(call) { Spectator::MethodCall.capture(:bar, "foobar") }

      it "returns false" do
        is_expected.to be_false
      end
    end

    context "with a constraint" do
      let(constraint) { Spectator::Arguments.capture(/foo/) }
      let(stub) { described_class.new(:foo, constraint) }

      context "with a matching method name" do
        let(call) { Spectator::MethodCall.capture(:foo, "foobar") }

        it "returns true" do
          is_expected.to be_true
        end

        context "with a non-matching arguments" do
          let(call) { Spectator::MethodCall.capture(:foo, "baz") }

          it "returns false" do
            is_expected.to be_false
          end
        end
      end

      context "with a different method name" do
        let(call) { Spectator::MethodCall.capture(:bar, "foobar") }

        it "returns false" do
          is_expected.to be_false
        end
      end
    end
  end
end
