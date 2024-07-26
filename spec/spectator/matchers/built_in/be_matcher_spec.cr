require "../../../spec_helper"

alias BeMatcher = Spectator::Matchers::BuiltIn::BeMatcher

Spectator.describe BeMatcher do
  describe "#matches?" do
    it "returns true if the objects are the same" do
      object = [] of Int32
      matcher = BeMatcher.new(object)
      expect(matcher.matches?(object)).to be_true
    end

    it "returns false if the objects are different" do
      matcher = BeMatcher.new([1, 2, 3])
      expect(matcher.matches?([] of Int32)).to be_false
    end

    it "returns false if the objects are different classes" do
      matcher = BeMatcher.new([] of String)
      expect(matcher.matches?({} of String => String)).to be_false
    end

    it "returns true if the values are the same" do
      matcher = BeMatcher.new(1)
      expect(matcher.matches?(1)).to be_true
    end

    it "returns false if the values are different" do
      matcher = BeMatcher.new(1)
      expect(matcher.matches?(2)).to be_false
    end

    it "returns false if the values are different types" do
      matcher = BeMatcher.new(1)
      expect(matcher.matches?(1.0)).to be_false
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      object_a = [] of Int32
      object_b = [] of Int32
      matcher = BeMatcher.new(object_b)
      expect(matcher.failure_message(object_a)).to eq <<-MESSAGE
        Expected: #{object_a.pretty_inspect} (object_id: #{object_a.object_id})
           to be: #{object_b.pretty_inspect} (object_id: #{object_b.object_id})
        MESSAGE
    end

    it "includes the type for values" do
      matcher = BeMatcher.new(1)
      expect(matcher.failure_message(2)).to eq <<-MESSAGE
        Expected: 2 : Int32
           to be: 1 : Int32
        MESSAGE
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      object = [] of Int32
      matcher = BeMatcher.new(object)
      expect(matcher.negated_failure_message(object)).to eq <<-MESSAGE
         Expected: #{object.pretty_inspect} (object_id: #{object.object_id})
        not to be: #{object.pretty_inspect} (object_id: #{object.object_id})
        MESSAGE
    end

    it "includes the type for values" do
      matcher = BeMatcher.new(1)
      expect(matcher.negated_failure_message(1)).to eq <<-MESSAGE
         Expected: 1 : Int32
        not to be: 1 : Int32
        MESSAGE
    end
  end

  describe "DSL" do
    describe "`be`" do
      context "with `.to`" do
        it "matches if the objects are the same" do
          object = [] of Int32
          expect do
            expect(object).to be(object)
          end.to pass_check
        end

        it "does not match if the objects are different" do
          object_a = [] of Int32
          object_b = [] of Int32
          expect do
            expect(object_a).to be(object_b)
          end.to fail_check <<-MESSAGE
            Expected: #{object_a.pretty_inspect} (object_id: #{object_a.object_id})
               to be: #{object_b.pretty_inspect} (object_id: #{object_b.object_id})
            MESSAGE
        end

        it "does not match if the objects are different classes" do
          object_a = [] of String
          object_b = {} of String => String
          expect do
            expect(object_a).to be(object_b)
          end.to fail_check <<-MESSAGE
            Expected: #{object_a.pretty_inspect} (object_id: #{object_a.object_id})
               to be: #{object_b.pretty_inspect} (object_id: #{object_b.object_id})
            MESSAGE
        end

        it "matches if the values are the same" do
          expect do
            expect(1).to be(1)
          end.to pass_check
        end

        it "does not match if the values are different" do
          expect do
            expect(1).to be(2)
          end.to fail_check <<-MESSAGE
            Expected: 1 : Int32
               to be: 2 : Int32
            MESSAGE
        end

        it "does not match if the values are different types" do
          expect do
            expect(1).to be(1.0)
          end.to fail_check <<-MESSAGE
            Expected: 1 : Int32
               to be: 1.0 : Float64
            MESSAGE
        end
      end

      context "with `.not_to`" do
        it "does not match if the objects are the same" do
          object = [] of Int32
          expect do
            expect(object).not_to be(object)
          end.to fail_check <<-MESSAGE
             Expected: #{object.pretty_inspect} (object_id: #{object.object_id})
            not to be: #{object.pretty_inspect} (object_id: #{object.object_id})
            MESSAGE
        end

        it "matches if the objects are different" do
          expect do
            expect([] of Int32).not_to be([] of Int32)
          end.to pass_check
        end

        it "matches if the objects are different classes" do
          expect do
            expect([] of String).not_to be({} of String => String)
          end.to pass_check
        end

        it "does not match if the values are the same" do
          expect do
            expect(1).not_to be(1)
          end.to fail_check <<-MESSAGE
             Expected: 1 : Int32
            not to be: 1 : Int32
            MESSAGE
        end

        it "matches if the values are different" do
          expect do
            expect(1).not_to be(2)
          end.to pass_check
        end

        it "matches if the values are different types" do
          expect do
            expect(1).not_to be(1.0)
          end.to pass_check
        end
      end
    end
  end
end
