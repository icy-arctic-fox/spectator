require "../../../spec_helper"

private struct MatchObject
  def initialize(@match : Bool = true)
  end

  def =~(other)
    @match ? 0 : nil
  end
end

alias MatchMatcher = Spectator::Matchers::BuiltIn::MatchMatcher

Spectator.describe MatchMatcher do
  describe "#matches?" do
    it "returns true if the value matches" do
      matcher = MatchMatcher.new(nil)
      object = MatchObject.new
      expect(matcher.matches?(object)).to be_true
    end

    it "returns false if the value does not match" do
      matcher = MatchMatcher.new(nil)
      object = MatchObject.new(false)
      expect(matcher.matches?(object)).to be_false
    end

    context "with a string" do
      it "returns true if the string matches" do
        matcher = MatchMatcher.new(/foo/)
        expect(matcher.matches?("foobar")).to be_true
      end

      it "returns false if the string does not match" do
        matcher = MatchMatcher.new(/foo/)
        expect(matcher.matches?("bar")).to be_false
      end
    end

    context "with a regex" do
      it "returns true if the regex matches" do
        matcher = MatchMatcher.new("foobar")
        expect(matcher.matches?(/foo/)).to be_true
      end

      it "returns false if the regex does not match" do
        matcher = MatchMatcher.new("bar")
        expect(matcher.matches?(/foo/)).to be_false
      end
    end
  end

  describe "#failure_message" do
    it "returns the failure message" do
      matcher = MatchMatcher.new(nil)
      object = MatchObject.new
      expect(matcher.failure_message(object)).to eq <<-MESSAGE
        Expected: #{object.pretty_inspect}
        to match: nil
        MESSAGE
    end

    context "with a string" do
      it "returns the failure message" do
        matcher = MatchMatcher.new(/foo/)
        expect(matcher.failure_message("bar")).to eq <<-MESSAGE
          Expected: "bar"
          to match: /foo/
          MESSAGE
      end
    end

    context "with a regex" do
      it "returns the failure message" do
        matcher = MatchMatcher.new("foobar")
        expect(matcher.failure_message(/foo/)).to eq <<-MESSAGE
          Expected: /foo/
          to match: "foobar"
          MESSAGE
      end
    end
  end

  describe "#negated_failure_message" do
    it "returns the negated failure message" do
      matcher = MatchMatcher.new(nil)
      object = MatchObject.new
      expect(matcher.negated_failure_message(object)).to eq <<-MESSAGE
            Expected: #{object.pretty_inspect}
        not to match: nil
        MESSAGE
    end

    context "with a string" do
      it "returns the negated failure message" do
        matcher = MatchMatcher.new(/foo/)
        expect(matcher.negated_failure_message("bar")).to eq <<-MESSAGE
              Expected: "bar"
          not to match: /foo/
          MESSAGE
      end
    end

    context "with a regex" do
      it "returns the negated failure message" do
        matcher = MatchMatcher.new("foobar")
        expect(matcher.negated_failure_message(/foo/)).to eq <<-MESSAGE
              Expected: /foo/
          not to match: "foobar"
          MESSAGE
      end
    end
  end

  describe "DSL" do
    context "with .to" do
      it "matches if the value matches" do
        expect do
          expect(MatchObject.new).to match(nil)
        end.to pass_check
      end

      it "does not match if the value does not match" do
        object = MatchObject.new(false)
        expect do
          expect(object).to match(nil)
        end.to fail_check <<-MESSAGE
          Expected: #{object.pretty_inspect}
          to match: nil
          MESSAGE
      end

      context "with a string" do
        it "matches if the string matches" do
          expect do
            expect(/foo/).to match("foobar")
          end.to pass_check
        end

        it "does not match if the string does not match" do
          expect do
            expect(/foo/).to match("bar")
          end.to fail_check <<-MESSAGE
            Expected: /foo/
            to match: "bar"
            MESSAGE
        end
      end

      context "with a regex" do
        it "matches if the regex matches" do
          expect do
            expect("foobar").to match(/foo/)
          end.to pass_check
        end

        it "does not match if the regex does not match" do
          expect do
            expect("bar").to match(/foo/)
          end.to fail_check("Expected: \"bar\"\nto match: /foo/")
        end
      end
    end

    context "with .not_to" do
      it "does not match if the value matches" do
        object = MatchObject.new
        expect do
          expect(object).not_to match(nil)
        end.to fail_check <<-MESSAGE
              Expected: #{object}
          not to match: nil
          MESSAGE
      end

      it "matches if the value does not match" do
        expect do
          expect(MatchObject.new(false)).not_to match(nil)
        end.to pass_check
      end

      context "with a string" do
        it "does not match if the string matches" do
          expect do
            expect(/foo/).not_to match("foobar")
          end.to fail_check <<-MESSAGE
                Expected: /foo/
            not to match: "foobar"
            MESSAGE
        end

        it "matches if the string does not match" do
          expect do
            expect(/foo/).not_to match("bar")
          end.to pass_check
        end
      end

      context "with a regex" do
        it "does not match if the regex matches" do
          expect do
            expect("foobar").not_to match(/foo/)
          end.to fail_check <<-MESSAGE
                Expected: "foobar"
            not to match: /foo/
            MESSAGE
        end

        it "matches if the regex does not match" do
          expect do
            expect("bar").not_to match(/foo/)
          end.to pass_check
        end
      end
    end
  end
end
