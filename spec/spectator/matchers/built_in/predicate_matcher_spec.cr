require "../../../spec_helper"

private struct PredicateObject
  getter? something : Bool

  def initialize(@something : Bool = true)
  end
end

private struct PredicateObjectWithArgs
  def has_another?(arg_a, arg_b)
    arg_a && arg_b
  end
end

alias PredicateMatcher = Spectator::Matchers::BuiltIn::PredicateMatcher

def create_predicate_matcher
  PredicateMatcher.create("something?", "be something")
end

macro create_predicate_matcher_with_args(*args)
  PredicateMatcher.create("has_another?", "have another", {{ args.splat }})
end

Spectator.describe PredicateMatcher do
  describe "#matches?" do
    it "returns true if the method returns truthy" do
      matcher = create_predicate_matcher
      object = PredicateObject.new
      expect(matcher.matches?(object)).to be_true
    end

    it "returns false if the method returns falsey" do
      matcher = create_predicate_matcher
      object = PredicateObject.new(false)
      expect(matcher.matches?(object)).to be_false
    end

    context "with arguments" do
      it "returns true if the method returns truthy" do
        matcher = create_predicate_matcher_with_args(true, true)
        object = PredicateObjectWithArgs.new
        expect(matcher.matches?(object)).to be_true
      end

      it "returns false if the method returns falsey" do
        matcher = create_predicate_matcher_with_args(true, false)
        object = PredicateObjectWithArgs.new
        expect(matcher.matches?(object)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = create_predicate_matcher
      object = PredicateObject.new
      expect(matcher.failure_message(object)).to eq("Expected #{object.pretty_inspect} to be something")
    end

    it "includes arguments" do
      matcher = create_predicate_matcher_with_args(true, false)
      object = PredicateObjectWithArgs.new
      expect(matcher.failure_message(object)).to eq("Expected #{object.pretty_inspect} to have another(true, false)")
    end
  end

  describe "#negated_failure_message" do
    it "returns the negative failure message" do
      matcher = create_predicate_matcher
      object = PredicateObject.new
      expect(matcher.negated_failure_message(object)).to eq("Expected #{object.pretty_inspect} not to be something")
    end

    it "includes arguments" do
      matcher = create_predicate_matcher_with_args(true, false)
      object = PredicateObjectWithArgs.new
      expect(matcher.negated_failure_message(object)).to eq("Expected #{object.pretty_inspect} not to have another(true, false)")
    end
  end

  describe "#to_s" do
    it "returns the description" do
      matcher = create_predicate_matcher
      expect(matcher.to_s).to eq("be something")
    end

    it "includes arguments" do
      matcher = create_predicate_matcher_with_args(true, false)
      expect(matcher.to_s).to eq("have another(true, false)")
    end
  end

  context "DSL" do
    describe "`be_`" do
      context "with `.to`" do
        it "matches if the method returns truthy" do
          object = PredicateObject.new
          expect do
            expect(object).to be_(:something)
          end.to pass_check
        end

        it "does not match if the method returns falsey" do
          object = PredicateObject.new(false)
          expect do
            expect(object).to be_(:something)
          end.to fail_check("Expected #{object.pretty_inspect} to be something")
        end
      end

      context "with `.not_to`" do
        it "does not match if the method returns truthy" do
          object = PredicateObject.new
          expect do
            expect(object).not_to be_(:something)
          end.to fail_check("Expected #{object.pretty_inspect} not to be something")
        end

        it "matches if the method returns falsey" do
          object = PredicateObject.new(false)
          expect do
            expect(object).not_to be_(:something)
          end.to pass_check
        end
      end
    end

    describe "`have_`" do
      context "with `.to`" do
        it "matches if the method returns truthy" do
          object = PredicateObjectWithArgs.new
          expect do
            expect(object).to have_(:another, true, true)
          end.to pass_check
        end

        it "does not match if the method returns falsey" do
          object = PredicateObjectWithArgs.new
          expect do
            expect(object).to have_(:another, true, false)
          end.to fail_check("Expected #{object.pretty_inspect} to have another(true, false)")
        end
      end

      context "with `.not_to`" do
        it "does not match if the method returns truthy" do
          object = PredicateObjectWithArgs.new
          expect do
            expect(object).not_to have_(:another, true, true)
          end.to fail_check("Expected #{object.pretty_inspect} not to have another(true, true)")
        end

        it "matches if the method returns falsey" do
          object = PredicateObjectWithArgs.new
          expect do
            expect(object).not_to have_(:another, true, false)
          end.to pass_check
        end
      end
    end
  end
end
