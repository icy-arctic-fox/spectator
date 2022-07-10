require "../../spec_helper"

Spectator.describe Spectator::MultiValueStub do
  let(method_call) { Spectator::MethodCall.capture(:foo) }
  let(location) { Spectator::Location.new(__FILE__, __LINE__) }
  subject(stub) { described_class.new(:foo, [3, 5, 7], location: location) }

  it "stores the method name" do
    expect(stub.method).to eq(:foo)
  end

  it "stores the location" do
    expect(stub.location).to eq(location)
  end

  describe "#call" do
    it "returns the values in order" do
      values = Array.new(3) { stub.call(method_call) }
      expect(values).to eq([3, 5, 7])
    end

    it "returns the final value after exhausting other values" do
      values = Array.new(5) { stub.call(method_call) }
      expect(values).to eq([3, 5, 7, 7, 7])
    end
  end

  context Spectator::StubModifiers do
    describe "#and_return(value)" do
      let(arguments) { Spectator::Arguments.capture(/foo/) }
      let(location) { Spectator::Location.new(__FILE__, __LINE__) }
      let(original) { Spectator::MultiValueStub.new(:foo, [3, 5, 7], arguments, location) }
      subject(stub) { original.and_return(123) }

      it "produces a stub that returns a value" do
        expect(stub.call(method_call)).to eq(123)
      end

      it "retains the method name" do
        expect(stub.method).to eq(:foo)
      end

      it "retains the arguments constraint" do
        expect(stub.constraint).to eq(arguments)
      end

      it "retains the location" do
        expect(stub.location).to eq(location)
      end
    end

    describe "#and_return(*values)" do
      let(arguments) { Spectator::Arguments.capture(/foo/) }
      let(location) { Spectator::Location.new(__FILE__, __LINE__) }
      let(original) { Spectator::MultiValueStub.new(:foo, [3, 5, 7], arguments, location) }
      subject(stub) { original.and_return(3, 2, 1, 0) }

      it "produces a stub that returns values" do
        values = Array.new(5) { stub.call(method_call) }
        expect(values).to eq([3, 2, 1, 0, 0])
      end

      it "retains the method name" do
        expect(stub.method).to eq(:foo)
      end

      it "retains the arguments constraint" do
        expect(stub.constraint).to eq(arguments)
      end

      it "retains the location" do
        expect(stub.location).to eq(location)
      end
    end

    describe "#and_raise" do
      let(arguments) { Spectator::Arguments.capture(/foo/) }
      let(location) { Spectator::Location.new(__FILE__, __LINE__) }
      let(original) { Spectator::MultiValueStub.new(:foo, [3, 5, 7], arguments, location) }
      let(new_exception) { ArgumentError.new("Test argument error") }
      subject(stub) { original.and_raise(new_exception) }

      it "produces a stub that raises" do
        expect { stub.call(method_call) }.to raise_error(ArgumentError, "Test argument error")
      end

      context "with a class and message" do
        subject(stub) { original.and_raise(ArgumentError, "Test argument error") }

        it "produces a stub that raises" do
          expect { stub.call(method_call) }.to raise_error(ArgumentError, "Test argument error")
        end
      end

      context "with a message" do
        subject(stub) { original.and_raise("Test exception") }

        it "produces a stub that raises" do
          expect { stub.call(method_call) }.to raise_error(Exception, "Test exception")
        end
      end

      context "with a class" do
        subject(stub) { original.and_raise(ArgumentError) }

        it "produces a stub that raises" do
          expect { stub.call(method_call) }.to raise_error(ArgumentError)
        end
      end

      it "retains the method name" do
        expect(stub.method).to eq(:foo)
      end

      it "retains the arguments constraint" do
        expect(stub.constraint).to eq(arguments)
      end

      it "retains the location" do
        expect(stub.location).to eq(location)
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
      let(stub) { Spectator::ValueStub.new(:foo, 42, constraint) }

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
