require "../../../spec_helper"

alias BeBetweenMatcher = Spectator::Matchers::BuiltIn::BeBetweenMatcher

Spectator.describe BeBetweenMatcher do
  describe "#matches?" do
    it "returns true if the value is between the min and max" do
      matcher = BeBetweenMatcher.new(40, 50)
      expect(matcher.matches?(42)).to be_true
    end

    it "returns false if the value is less than the min" do
      matcher = BeBetweenMatcher.new(40, 50)
      expect(matcher.matches?(38)).to be_false
    end

    it "returns false if the value is greater than the max" do
      matcher = BeBetweenMatcher.new(40, 50)
      expect(matcher.matches?(52)).to be_false
    end

    it "is inclusive by default" do
      matcher = BeBetweenMatcher.new(40, 50)
      expect(matcher.matches?(40)).to be_true
      expect(matcher.matches?(50)).to be_true
    end

    context "inclusive" do
      it "returns true if the value is equal to the min" do
        matcher = BeBetweenMatcher.new(40, 50).inclusive
        expect(matcher.matches?(40)).to be_true
      end

      it "returns true if the value is equal to the max" do
        matcher = BeBetweenMatcher.new(40, 50).inclusive
        expect(matcher.matches?(50)).to be_true
      end

      it "returns false if the value is less than the min" do
        matcher = BeBetweenMatcher.new(40, 50).inclusive
        expect(matcher.matches?(38)).to be_false
      end

      it "returns false if the value is greater than the max" do
        matcher = BeBetweenMatcher.new(40, 50).inclusive
        expect(matcher.matches?(52)).to be_false
      end

      it "returns true if the value is between the min and max" do
        matcher = BeBetweenMatcher.new(40, 50).inclusive
        expect(matcher.matches?(42)).to be_true
      end
    end

    context "exclusive" do
      it "returns false if the value is equal to the min" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.matches?(40)).to be_false
      end

      it "returns false if the value is equal to the max" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.matches?(50)).to be_false
      end

      it "returns false if the value is less than the min" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.matches?(38)).to be_false
      end

      it "returns false if the value is greater than the max" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.matches?(52)).to be_false
      end

      it "returns true if the value is between the min and max" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.matches?(42)).to be_true
      end
    end
  end

  describe "#failure_message" do
    context "inclusive" do
      it "returns the inclusive failure message" do
        matcher = BeBetweenMatcher.new(40, 50).inclusive
        expect(matcher.failure_message(30)).to eq <<-MESSAGE
               Expected: 30
          to be between: 40 and 50 (inclusive)
          MESSAGE
      end
    end

    context "exclusive" do
      it "returns the exclusive failure message" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.failure_message(30)).to eq <<-MESSAGE
               Expected: 30
          to be between: 40 and 50 (exclusive)
          MESSAGE
      end
    end
  end

  describe "#negated_failure_message" do
    context "inclusive" do
      it "returns the negated failure message" do
        matcher = BeBetweenMatcher.new(40, 50)
        expect(matcher.negated_failure_message(30)).to eq <<-MESSAGE
               Expected: 30
          to be outside: 40 and 50 (inclusive)
          MESSAGE
      end
    end

    context "exclusive" do
      it "returns the negated failure message" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.negated_failure_message(30)).to eq <<-MESSAGE
               Expected: 30
          to be outside: 40 and 50 (exclusive)
          MESSAGE
      end
    end
  end

  describe "#to_s" do
    context "inclusive" do
      it "returns the description" do
        matcher = BeBetweenMatcher.new(40, 50)
        expect(matcher.to_s).to eq "be between 40 and 50 (inclusive)"
      end
    end

    context "exclusive" do
      it "returns the description" do
        matcher = BeBetweenMatcher.new(40, 50).exclusive
        expect(matcher.to_s).to eq "be between 40 and 50 (exclusive)"
      end
    end
  end

  context "DSL" do
    describe "`be_between`" do
      it "is inclusive by default" do
        expect do
          expect(40).to be_between(40, 50)
        end.to pass_check
        expect do
          expect(50).to be_between(40, 50)
        end.to pass_check
      end

      context "with `.to`" do
        it "matches if the value is between the min and max" do
          expect do
            expect(42).to be_between(40, 50)
          end.to pass_check
        end

        it "does not match if the value is less than the min" do
          expect do
            expect(38).to be_between(40, 50)
          end.to fail_check <<-MESSAGE
                 Expected: 38
            to be between: 40 and 50 (inclusive)
            MESSAGE
        end

        it "does not match if the value is greater than the max" do
          expect do
            expect(52).to be_between(40, 50)
          end.to fail_check <<-MESSAGE
                 Expected: 52
            to be between: 40 and 50 (inclusive)
            MESSAGE
        end

        describe "inclusive" do
          it "matches if the value is equal to the min" do
            expect do
              expect(40).to be_between(40, 50).inclusive
            end.to pass_check
          end

          it "matches if the value is equal to the max" do
            expect do
              expect(50).to be_between(40, 50).inclusive
            end.to pass_check
          end

          it "does not match if the value is less than the min" do
            expect do
              expect(38).to be_between(40, 50).inclusive
            end.to fail_check <<-MESSAGE
                   Expected: 38
              to be between: 40 and 50 (inclusive)
              MESSAGE
          end

          it "does not match if the value is greater than the max" do
            expect do
              expect(52).to be_between(40, 50).inclusive
            end.to fail_check <<-MESSAGE
                   Expected: 52
              to be between: 40 and 50 (inclusive)
              MESSAGE
          end

          it "matches if the value is between the min and max" do
            expect do
              expect(42).to be_between(40, 50).inclusive
            end.to pass_check
          end
        end

        describe "exclusive" do
          it "does not match if the value is equal to the min" do
            expect do
              expect(40).to be_between(40, 50).exclusive
            end.to fail_check <<-MESSAGE
                   Expected: 40
              to be between: 40 and 50 (exclusive)
              MESSAGE
          end

          it "does not match if the value is equal to the max" do
            expect do
              expect(50).to be_between(40, 50).exclusive
            end.to fail_check <<-MESSAGE
                   Expected: 50
              to be between: 40 and 50 (exclusive)
              MESSAGE
          end

          it "does not match if the value is less than the min" do
            expect do
              expect(38).to be_between(40, 50).exclusive
            end.to fail_check <<-MESSAGE
                   Expected: 38
              to be between: 40 and 50 (exclusive)
              MESSAGE
          end

          it "does not match if the value is greater than the max" do
            expect do
              expect(52).to be_between(40, 50).exclusive
            end.to fail_check <<-MESSAGE
                   Expected: 52
              to be between: 40 and 50 (exclusive)
              MESSAGE
          end

          it "matches if the value is between the min and max" do
            expect do
              expect(42).to be_between(40, 50).exclusive
            end.to pass_check
          end
        end
      end

      context "with `.not_to`" do
        it "does not match if the value is between the min and max" do
          expect do
            expect(42).not_to be_between(40, 50)
          end.to fail_check <<-MESSAGE
                 Expected: 42
            to be outside: 40 and 50 (inclusive)
            MESSAGE
        end

        it "matches if the value is less than the min" do
          expect do
            expect(38).not_to be_between(40, 50)
          end.to pass_check
        end

        it "matches if the value is greater than the max" do
          expect do
            expect(52).not_to be_between(40, 50)
          end.to pass_check
        end

        describe "inclusive" do
          it "does not match if the value is equal to the min" do
            expect do
              expect(40).not_to be_between(40, 50).inclusive
            end.to fail_check <<-MESSAGE
                   Expected: 40
              to be outside: 40 and 50 (inclusive)
              MESSAGE
          end

          it "does not match if the value is equal to the max" do
            expect do
              expect(50).not_to be_between(40, 50).inclusive
            end.to fail_check <<-MESSAGE
                   Expected: 50
              to be outside: 40 and 50 (inclusive)
              MESSAGE
          end

          it "matches if the value is less than the min" do
            expect do
              expect(38).not_to be_between(40, 50).inclusive
            end.to pass_check
          end

          it "matches if the value is greater than the max" do
            expect do
              expect(52).not_to be_between(40, 50).inclusive
            end.to pass_check
          end

          it "does not match if the value is between the min and max" do
            expect do
              expect(42).not_to be_between(40, 50).inclusive
            end.to fail_check <<-MESSAGE
                   Expected: 42
              to be outside: 40 and 50 (inclusive)
              MESSAGE
          end
        end

        describe "exclusive" do
          it "matches if the value is equal to the min" do
            expect do
              expect(40).not_to be_between(40, 50).exclusive
            end.to pass_check
          end

          it "matches if the value is equal to the max" do
            expect do
              expect(50).not_to be_between(40, 50).exclusive
            end.to pass_check
          end

          it "matches if the value is less than the min" do
            expect do
              expect(38).not_to be_between(40, 50).exclusive
            end.to pass_check
          end

          it "matches if the value is greater than the max" do
            expect do
              expect(52).not_to be_between(40, 50).exclusive
            end.to pass_check
          end

          it "does not match if the value is between the min and max" do
            expect do
              expect(42).not_to be_between(40, 50).exclusive
            end.to fail_check <<-MESSAGE
                   Expected: 42
              to be outside: 40 and 50 (exclusive)
              MESSAGE
          end
        end
      end
    end
  end
end
