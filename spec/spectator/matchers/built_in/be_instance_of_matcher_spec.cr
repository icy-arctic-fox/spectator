require "../../../spec_helper"

private class Base
end

private class Derived < Base
end

alias BeInstanceOfMatcher = Spectator::Matchers::BuiltIn::BeInstanceOfMatcher

Spectator.describe BeInstanceOfMatcher do
  describe "#matches?" do
    it "returns true if the object is the exact type" do
      matcher = BeInstanceOfMatcher(Base).new
      expect(matcher.matches?(Base.new)).to be_true
    end

    it "returns false if the object is a sub-type" do
      matcher = BeInstanceOfMatcher(Base).new
      expect(matcher.matches?(Derived.new)).to be_false
    end

    it "returns false if the object is a parent type" do
      matcher = BeInstanceOfMatcher(Derived).new
      expect(matcher.matches?(Base.new)).to be_false
    end

    it "returns false if the object is an unrelated type" do
      matcher = BeInstanceOfMatcher(Int32).new
      expect(matcher.matches?("foo")).to be_false
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = BeInstanceOfMatcher(Int32).new
      expect(matcher.failure_message("foo")).to eq <<-MESSAGE
         Expected: "foo"
          to be a: Int32
        but was a: String
        MESSAGE
    end

    it "returns an extended failure message for sub-types" do
      matcher = BeInstanceOfMatcher(Base).new
      object = Derived.new
      expect(matcher.failure_message(object)).to eq <<-MESSAGE
         Expected: #{object.pretty_inspect}
          to be a: Base
        but was a: Derived

        Derived is a sub-type of Base.
        Using `be_instance_of` ensures the type matches EXACTLY.
        If you want to match sub-types, use `be_a` instead.
        MESSAGE
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = BeInstanceOfMatcher(String).new
      expect(matcher.negated_failure_message("foo")).to eq <<-MESSAGE
         Expected: "foo"
      not to be a: String
      MESSAGE
    end
  end

  describe "DSL" do
    describe "`be_instance_of`" do
      context "with `.to`" do
        it "matches if the object is the exact type" do
          expect do
            expect("foo").to be_instance_of(String)
          end.to pass_check
        end

        it "does not match if the object is a sub-type" do
          object = Derived.new
          expect do
            expect(object).to be_instance_of(Base)
          end.to fail_check <<-MESSAGE
             Expected: #{object.pretty_inspect}
              to be a: Base
            but was a: Derived

            Derived is a sub-type of Base.
            Using `be_instance_of` ensures the type matches EXACTLY.
            If you want to match sub-types, use `be_a` instead.
            MESSAGE
        end

        # FIXME: Enabling this test causes a segfault.
        # This only occurs when running all specs, not just this file.
        # To reproduce, uncomment this test and run `crystal spec`.
        # it "does not match if the object is a parent type" do
        #   object = Base.new
        #   expect do
        #     expect(object).to be_instance_of(Derived)
        #   end.to fail_check <<-MESSAGE
        #      Expected: #{object.pretty_inspect}
        #       to be a: Derived
        #     but was a: Base
        #     MESSAGE
        # end

        it "does not match if the object is an unrelated type" do
          expect do
            expect("foo").to be_instance_of(Int32)
          end.to fail_check <<-MESSAGE
             Expected: "foo"
              to be a: Int32
            but was a: String
            MESSAGE
        end
      end

      context "with `.not_to`" do
        it "does not match if the object is the exact type" do
          expect do
            expect("foo").not_to be_instance_of(String)
          end.to fail_check <<-MESSAGE
               Expected: "foo"
            not to be a: String
            MESSAGE
        end

        it "matches if the object is a sub-type" do
          expect do
            expect(Derived.new).not_to be_instance_of(Base)
          end.to pass_check
        end

        # FIXME: Enabling this test causes a segfault.
        # This only occurs when running all specs, not just this file.
        # To reproduce, uncomment this test and run `crystal spec`.
        # it "matches if the object is a parent type" do
        #   expect do
        #     expect(Base.new).not_to be_instance_of(Derived)
        #   end.to pass_check
        # end

        it "matches if the object is an unrelated type" do
          expect do
            expect("foo").not_to be_instance_of(Int32)
          end.to pass_check
        end
      end
    end
  end
end
