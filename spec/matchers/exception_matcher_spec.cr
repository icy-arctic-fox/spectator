require "../spec_helper"

describe Spectator::Matchers::ExceptionMatcher do
  describe "#match" do
    it "compares the message using #===" do
      spy = SpySUT.new
      partial = new_block_partial { raise "foobar" }
      matcher = Spectator::Matchers::ExceptionMatcher(Exception, SpySUT).new(spy, "foo")
      matcher.match(partial)
      spy.case_eq_call_count.should be > 0
    end

    context "returned MatchData" do
      describe "#matched?" do
        context "with no exception" do
          it "is false" do
            partial = new_block_partial { 42 }
            matcher = Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
            match_data = matcher.match(partial)
            match_data.matched?.should be_false
          end
        end

        context "with an exception" do
          context "of the same type" do
            it "is true" do
              partial = new_block_partial { raise ArgumentError.new }
              matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, Nil).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "of a different type" do
            it "is false" do
              partial = new_block_partial { raise ArgumentError.new }
              matcher = Spectator::Matchers::ExceptionMatcher(KeyError, Nil).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "of a sub-type" do
            it "is true" do
              partial = new_block_partial { raise ArgumentError.new }
              matcher = Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "and an equal message" do
            it "is true" do
              message = "foobar"
              partial = new_block_partial { raise ArgumentError.new(message) }
              matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, String).new(message, "label")
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "and a different message" do
            it "is false" do
              partial = new_block_partial { raise ArgumentError.new("foobar") }
              matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, String).new("different", "label")
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "and a matching regex" do
            it "is true" do
              partial = new_block_partial { raise ArgumentError.new("foobar") }
              matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, Regex).new(/foo/, "label")
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "and a non-matching regex" do
            it "is false" do
              partial = new_block_partial { raise ArgumentError.new("foobar") }
              matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, Regex).new(/baz/, "label")
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end
      end

      describe "#values" do
        describe "expected type" do
          it "is the exception type" do
            partial = new_block_partial { raise ArgumentError.new }
            matcher = Spectator::Matchers::ExceptionMatcher(KeyError, Nil).new
            match_data = matcher.match(partial)
            match_data_prefix(match_data, :"expected type")[:value].should eq(KeyError)
          end
        end

        describe "actual type" do
          it "is the raised type" do
            partial = new_block_partial { raise ArgumentError.new }
            matcher = Spectator::Matchers::ExceptionMatcher(KeyError, Nil).new
            match_data = matcher.match(partial)
            match_data_prefix(match_data, :"actual type")[:value].should eq(ArgumentError)
          end

          context "when nothing is raised" do
            it "is Nil" do
              partial = new_block_partial { 42 }
              matcher = Spectator::Matchers::ExceptionMatcher(KeyError, Nil).new
              match_data = matcher.match(partial)
              match_data_prefix(match_data, :"actual type")[:value].should eq(Nil)
            end
          end
        end

        describe "expected message" do
          it "is the expected value" do
            regex = /baz/
            partial = new_block_partial { raise ArgumentError.new("foobar") }
            matcher = Spectator::Matchers::ExceptionMatcher(KeyError, Regex).new(regex, "label")
            match_data = matcher.match(partial)
            match_data_prefix(match_data, :"expected message")[:value].should eq(regex)
          end
        end

        describe "actual message" do
          it "is the raised exception's message" do
            message = "foobar"
            partial = new_block_partial { raise ArgumentError.new(message) }
            matcher = Spectator::Matchers::ExceptionMatcher(KeyError, Regex).new(/baz/, "label")
            match_data = matcher.match(partial)
            match_data_prefix(match_data, :"actual message")[:value].should eq(message)
          end
        end
      end

      describe "#message" do
        it "mentions raise" do
          partial = new_block_partial { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
          match_data = matcher.match(partial)
          match_data.message.should contain("raise")
        end

        it "contains the actual label" do
          label = "everything"
          partial = new_block_partial(label) { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          label = "everything"
          partial = new_block_partial { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(Exception, Regex).new(/foobar/, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the exception type" do
          partial = new_block_partial { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, Nil).new
          match_data = matcher.match(partial)
          match_data.message.should contain("ArgumentError")
        end
      end

      describe "#negated_message" do
        it "mentions raise" do
          partial = new_block_partial { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("raise")
        end

        it "contains the actual label" do
          label = "everything"
          partial = new_block_partial(label) { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(Exception, Nil).new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          label = "everything"
          partial = new_block_partial { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(Exception, Regex).new(/foobar/, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the exception type" do
          partial = new_block_partial { raise "foobar" }
          matcher = Spectator::Matchers::ExceptionMatcher(ArgumentError, Nil).new
          match_data = matcher.match(partial)
          match_data.negated_message.should contain("ArgumentError")
        end
      end
    end
  end
end
