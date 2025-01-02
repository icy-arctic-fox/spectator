require "../../../spec_helper"

# Types used to test sub-classes.
private class Base
end

private class Derived < Base
end

private module Module
end

private struct Mod
  include Module
end

alias BeAMatcher = Spectator::Matchers::BuiltIn::BeAMatcher

Spectator.describe BeAMatcher do
  describe "#matches?" do
    it "returns true if the value is an instance of the type" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.matches?(42)).to be_true
    end

    it "returns false if the value is not an instance of the type" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.matches?("foo")).to be_false
    end

    it "returns false if the value is nil" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.matches?(nil)).to be_false
    end

    it "returns true if the value is a subclass of the type" do
      matcher = BeAMatcher(Base).new
      expect(matcher.matches?(Derived.new)).to be_true
    end

    it "returns false if the value is a parent of the type" do
      matcher = BeAMatcher(Derived).new
      expect(matcher.matches?(Base.new)).to be_false
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.failure_message("foo")).to eq <<-MESSAGE
         Expected: "foo"
          to be a: Int32
        but was a: String
        MESSAGE
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = BeAMatcher(String).new
      expect(matcher.negated_failure_message("foo")).to eq <<-MESSAGE
           Expected: "foo"
        not to be a: String
        MESSAGE
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = BeAMatcher(Int32).new
      expect(matcher.to_s).to eq("be a Int32")
    end
  end

  context "DSL" do
    describe "`be_a`" do
      context "with `.to`" do
        it "matches if the value is an instance of the type" do
          expect do
            expect(42).to be_a(Int32)
          end.to pass_check
        end

        it "does not match if the value is not an instance of the type" do
          expect do
            expect("foo").to be_a(Int32)
          end.to fail_check <<-MESSAGE
             Expected: "foo"
              to be a: Int32
            but was a: String
            MESSAGE
        end

        it "does not match if the value is nil" do
          expect do
            expect(nil).to be_a(Int32)
          end.to fail_check <<-MESSAGE
             Expected: nil
              to be a: Int32
            but was a: Nil
            MESSAGE
        end

        it "matches if the value is a subclass of the type" do
          expect do
            expect(Derived.new).to be_a(Base)
          end.to pass_check
        end

        it "does not match if the value is a parent of the type" do
          object = Base.new
          expect do
            expect(object).to be_a(Derived)
          end.to fail_check <<-MESSAGE
             Expected: #{object.pretty_inspect}
              to be a: Derived
            but was a: Base
            MESSAGE
        end

        it "matches a type that includes a module" do
          object = Mod.new
          expect do
            expect(object).to be_a(Module)
          end.to pass_check
        end

        it "doesn't match a differing generic type" do
          expect do
            expect([1, 2, 3]).to be_a(Array(Symbol))
          end.to fail_check <<-MESSAGE
             Expected: [1, 2, 3]
              to be a: Array(Symbol)
            but was a: Array(Int32)
            MESSAGE
        end

        it "matches a type that includes a generic module" do
          expect do
            expect([1, 2, 3]).to be_a(Enumerable(Int32))
          end.to pass_check
        end
      end

      context "with `.not_to`" do
        it "does not match if the value is an instance of the type" do
          expect do
            expect(42).not_to be_a(Int32)
          end.to fail_check <<-MESSAGE
               Expected: 42
            not to be a: Int32
            MESSAGE
        end

        it "matches if the value is not an instance of the type" do
          expect do
            expect("foo").not_to be_a(Int32)
          end.to pass_check
        end

        it "matches if the value is nil" do
          expect do
            expect(nil).not_to be_a(Int32)
          end.to pass_check
        end

        it "does not match if the value is a subclass of the type" do
          object = Derived.new
          expect do
            expect(object).not_to be_a(Base)
          end.to fail_check <<-MESSAGE
               Expected: #{object.pretty_inspect}
            not to be a: Base
            Derived is a sub-type of Base
            MESSAGE
        end

        it "matches if the value is a parent of the type" do
          expect do
            expect(Base.new).not_to be_a(Derived)
          end.to pass_check
        end

        it "doesn't match a type that includes a module" do
          object = Mod.new
          expect do
            expect(object).not_to be_a(Module)
          end.to fail_check <<-MESSAGE
               Expected: #{object.pretty_inspect}
            not to be a: Module
            Mod is a sub-type of Module
            MESSAGE
        end

        it "matches a differing generic type" do
          expect do
            expect([1, 2, 3]).not_to be_a(Array(Symbol))
          end.to pass_check
        end

        it "doesn't match a type that includes a generic module" do
          expect do
            expect([1, 2, 3]).not_to be_a(Enumerable(Int32))
          end.to fail_check <<-MESSAGE
               Expected: [1, 2, 3]
            not to be a: Enumerable(Int32)
            Array(Int32) is a sub-type of Enumerable(Int32)
            MESSAGE
        end
      end
    end

    describe "`be_an`" do
      context "with `.to`" do
        it "matches if the value is an instance of the type" do
          expect do
            expect(42).to be_an(Int32)
          end.to pass_check
        end

        it "does not match if the value is not an instance of the type" do
          expect do
            expect("foo").to be_an(Int32)
          end.to fail_check <<-MESSAGE
             Expected: "foo"
              to be a: Int32
            but was a: String
            MESSAGE
        end

        it "does not match if the value is nil" do
          expect do
            expect(nil).to be_an(Int32)
          end.to fail_check <<-MESSAGE
             Expected: nil
              to be a: Int32
            but was a: Nil
            MESSAGE
        end

        it "matches if the value is a subclass of the type" do
          expect do
            expect(Derived.new).to be_an(Base)
          end.to pass_check
        end

        it "does not match if the value is a parent of the type" do
          object = Base.new
          expect do
            expect(object).to be_an(Derived)
          end.to fail_check <<-MESSAGE
             Expected: #{object.pretty_inspect}
              to be a: Derived
            but was a: Base
            MESSAGE
        end

        it "matches a type that includes a module" do
          object = Mod.new
          expect do
            expect(object).to be_an(Module)
          end.to pass_check
        end

        it "doesn't match a differing generic type" do
          expect do
            expect([1, 2, 3]).to be_an(Array(Symbol))
          end.to fail_check <<-MESSAGE
             Expected: [1, 2, 3]
              to be a: Array(Symbol)
            but was a: Array(Int32)
            MESSAGE
        end

        it "matches a type that includes a generic module" do
          expect do
            expect([1, 2, 3]).to be_an(Enumerable(Int32))
          end.to pass_check
        end
      end

      context "with `.not_to`" do
        it "does not match if the value is an instance of the type" do
          expect do
            expect(42).not_to be_an(Int32)
          end.to fail_check <<-MESSAGE
               Expected: 42
            not to be a: Int32
            MESSAGE
        end

        it "matches if the value is not an instance of the type" do
          expect do
            expect("foo").not_to be_an(Int32)
          end.to pass_check
        end

        it "matches if the value is nil" do
          expect do
            expect(nil).not_to be_an(Int32)
          end.to pass_check
        end

        it "does not match if the value is a subclass of the type" do
          object = Derived.new
          expect do
            expect(object).not_to be_an(Base)
          end.to fail_check <<-MESSAGE
               Expected: #{object.pretty_inspect}
            not to be a: Base
            Derived is a sub-type of Base
            MESSAGE
        end

        it "matches if the value is a parent of the type" do
          expect do
            expect(Base.new).not_to be_an(Derived)
          end.to pass_check
        end

        it "doesn't match a type that includes a module" do
          object = Mod.new
          expect do
            expect(object).not_to be_an(Module)
          end.to fail_check <<-MESSAGE
               Expected: #{object.pretty_inspect}
            not to be a: Module
            Mod is a sub-type of Module
            MESSAGE
        end

        it "matches a differing generic type" do
          expect do
            expect([1, 2, 3]).not_to be_an(Array(Symbol))
          end.to pass_check
        end

        it "doesn't match a type that includes a generic module" do
          expect do
            expect([1, 2, 3]).not_to be_an(Enumerable(Int32))
          end.to fail_check <<-MESSAGE
               Expected: [1, 2, 3]
            not to be a: Enumerable(Int32)
            Array(Int32) is a sub-type of Enumerable(Int32)
            MESSAGE
        end
      end
    end
  end
end
