require "../spec_helper"

Spectator.describe Spectator::Matchers::ReceiveMatcher do
  let(stub) { Spectator::NullStub.new(:test_method) }
  subject(matcher) { described_class.new(stub) }

  let(args) { Spectator::Arguments.capture(1, "test", Symbol, foo: /bar/) }
  let(args_stub) { Spectator::NullStub.new(:test_method, args) }
  let(args_matcher) { described_class.new(args_stub) }

  let(no_args_stub) { Spectator::NullStub.new(:test_method, Spectator::Arguments.none) }
  let(no_args_matcher) { described_class.new(no_args_stub) }

  double(:dbl, test_method: nil, irrelevant: nil)
  let(dbl) { double(:dbl) }
  let(actual) { Spectator::Value.new(dbl, "dbl") }

  def successful_match
    Spectator::Matchers::SuccessfulMatchData
  end

  def failed_match
    Spectator::Matchers::FailedMatchData
  end

  describe "#description" do
    subject { matcher.description }

    it "includes the method name" do
      is_expected.to contain("test_method")
    end

    context "without an argument constraint" do
      it "mentions it accepts any arguments" do
        is_expected.to contain("any args")
      end
    end

    context "with no arguments" do
      let(matcher) { no_args_matcher }

      it "mentions there are none" do
        is_expected.to contain("no args")
      end
    end

    context "with arguments" do
      let(matcher) { args_matcher }

      it "lists the arguments" do
        is_expected.to contain("1, \"test\", Symbol, foo: #{/bar/.inspect}")
      end
    end
  end

  describe "#with" do
    subject { matcher.with(1, 2, 3, bar: /baz/) }

    it "applies a constraint on arguments" do
      dbl.test_method
      expect(&.match(actual)).to be_a(failed_match)
      dbl.test_method(1, 2, 3, bar: "foobarbaz")
      expect(&.match(actual)).to be_a(successful_match)
    end
  end

  describe "#match" do
    subject(match_data) { matcher.match(actual) }

    post_condition { expect(match_data.description).to contain("dbl received #test_method") }

    let(failure_message) { match_data.as(Spectator::Matchers::FailedMatchData).failure_message }

    context "with no argument constraint" do
      post_condition { expect(&.description).to contain("(any args)") }

      it "matches with no arguments" do
        dbl.test_method
        is_expected.to be_a(successful_match)
      end

      it "matches with any arguments" do
        dbl.test_method("foo")
        is_expected.to be_a(successful_match)
      end

      it "doesn't match with no calls" do
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(any args)")
      end

      it "doesn't match with different calls" do
        dbl.irrelevant("foo")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(any args)")
      end
    end

    context "with a \"no arguments\" constraint" do
      let(matcher) { no_args_matcher }

      post_condition { expect(&.description).to contain("(no args)") }

      it "matches with no arguments" do
        dbl.test_method
        is_expected.to be_a(successful_match)
      end

      it "doesn't match with arguments" do
        dbl.test_method("foo")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(no args)")
      end

      it "doesn't match with no calls" do
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(no args)")
      end

      it "doesn't match with different calls" do
        dbl.irrelevant("foo")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(no args)")
      end
    end

    context "with an arguments constraint" do
      let(matcher) { args_matcher }

      post_condition { expect(&.description).to contain("(1, \"test\", Symbol, foo: #{/bar/.inspect})") }

      it "doesn't match with no arguments" do
        dbl.test_method
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(1, \"test\", Symbol, foo: #{/bar/.inspect})")
      end

      it "matches with matching arguments" do
        dbl.test_method(1, "test", :xyz, foo: "foobarbaz")
        is_expected.to be_a(successful_match)
      end

      it "doesn't match with differing arguments" do
        dbl.test_method(1, "wrong", 42, foo: "wrong")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(1, \"test\", Symbol, foo: #{/bar/.inspect})")
      end

      it "doesn't match with no calls" do
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(1, \"test\", Symbol, foo: #{/bar/.inspect})")
      end

      it "doesn't match with different calls" do
        dbl.irrelevant("foo")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl did not receive #test_method(1, \"test\", Symbol, foo: #{/bar/.inspect})")
      end
    end

    describe "the match data values" do
      let(matcher) { args_matcher }
      subject(values) { match_data.as(Spectator::Matchers::FailedMatchData).values }

      pre_condition { expect(match_data).to be_a(failed_match) }

      it "has the expected call listed" do
        is_expected.to contain({:expected, "#test_method(1, \"test\", Symbol, foo: #{/bar/.inspect})"})
      end

      context "with method calls" do
        before do
          dbl.test_method
          dbl.test_method(1, "wrong", :xyz, foo: "foobarbaz")
          dbl.irrelevant("foo")
        end

        it "has the list of called methods" do
          is_expected.to contain({
            :actual,
            <<-SIGNATURES
            #test_method(no args)
            #test_method(1, "wrong", :xyz, foo: "foobarbaz")
            #irrelevant("foo")
            SIGNATURES
          })
        end
      end

      context "with no method calls" do
        it "reports \"None\" for the actual value" do
          is_expected.to contain({:actual, "None"})
        end
      end
    end
  end

  describe "#negated_match" do
    subject(match_data) { matcher.negated_match(actual) }

    post_condition { expect(match_data.description).to contain("dbl did not receive #test_method") }

    let(failure_message) { match_data.as(Spectator::Matchers::FailedMatchData).failure_message }

    context "with no argument constraint" do
      post_condition { expect(&.description).to contain("(any args)") }

      it "doesn't match with no arguments" do
        dbl.test_method
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl received #test_method(any args)")
      end

      it "doesn't match with any arguments" do
        dbl.test_method("foo")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl received #test_method(any args)")
      end

      it "matches with no calls" do
        is_expected.to be_a(successful_match)
      end

      it "matches with different calls" do
        dbl.irrelevant("foo")
        is_expected.to be_a(successful_match)
      end
    end

    context "with a \"no arguments\" constraint" do
      let(matcher) { no_args_matcher }

      post_condition { expect(&.description).to contain("(no args)") }

      it "doesn't match with no arguments" do
        dbl.test_method
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl received #test_method(no args)")
      end

      it "matches with arguments" do
        dbl.test_method("foo")
        is_expected.to be_a(successful_match)
      end

      it "matches with no calls" do
        is_expected.to be_a(successful_match)
      end

      it "matches with different calls" do
        dbl.irrelevant("foo")
        is_expected.to be_a(successful_match)
      end
    end

    context "with an arguments constraint" do
      let(matcher) { args_matcher }

      post_condition { expect(&.description).to contain("(1, \"test\", Symbol, foo: #{/bar/.inspect})") }

      it "matches with no arguments" do
        dbl.test_method
        is_expected.to be_a(successful_match)
      end

      it "doesn't match with matching arguments" do
        dbl.test_method(1, "test", :xyz, foo: "foobarbaz")
        is_expected.to be_a(failed_match)
        expect(failure_message).to eq("dbl received #test_method(1, \"test\", Symbol, foo: #{/bar/.inspect})")
      end

      it "matches with differing arguments" do
        dbl.test_method(1, "wrong", 42, foo: "wrong")
        is_expected.to be_a(successful_match)
      end

      it "matches with no calls" do
        is_expected.to be_a(successful_match)
      end

      it "matches with different calls" do
        dbl.irrelevant("foo")
        is_expected.to be_a(successful_match)
      end
    end

    describe "the match data values" do
      subject(values) { match_data.as(Spectator::Matchers::FailedMatchData).values }

      pre_condition { expect(match_data).to be_a(failed_match) }

      before do
        dbl.test_method
        dbl.test_method(1, "test", :xyz, foo: "foobarbaz")
        dbl.irrelevant("foo")
      end

      it "has the expected call listed" do
        is_expected.to contain({:expected, "Not #{stub.message}"})
      end

      it "has the list of called methods" do
        is_expected.to contain({
          :actual,
          <<-SIGNATURES
          #test_method(no args)
          #test_method(1, "test", :xyz, foo: "foobarbaz")
          #irrelevant("foo")
          SIGNATURES
        })
      end
    end
  end

  describe "#once" do
    let(matcher) { super.once }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called once" do
      dbl.test_method
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub isn't called" do
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub is called twice" do
      2.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end
  end

  describe "#twice" do
    let(matcher) { super.twice }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called twice" do
      2.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub isn't called" do
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub is called once" do
      dbl.test_method
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub is called thrice" do
      3.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end
  end

  describe "#exactly" do
    let(matcher) { super.exactly(3) }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called the exact amount" do
      3.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub isn't called" do
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub is called less than the amount" do
      2.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub is called more than the amount" do
      4.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end
  end

  describe "#at_least" do
    let(matcher) { super.at_least(3) }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called the exact amount" do
      3.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub isn't called" do
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub is called less than the amount" do
      2.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end

    it "matches when the stub is called more than the amount" do
      4.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end
  end

  describe "#at_most" do
    let(matcher) { super.at_most(3) }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called the exact amount" do
      3.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "matches when the stub isn't called" do
      is_expected.to be_a(successful_match)
    end

    it "matches when the stub is called less than the amount" do
      2.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub is called more than the amount" do
      4.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end
  end

  describe "#at_least_once" do
    let(matcher) { super.at_least_once }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called once" do
      dbl.test_method
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub isn't called" do
      is_expected.to be_a(failed_match)
    end

    it "matches when the stub is called more than once" do
      2.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end
  end

  describe "#at_least_twice" do
    let(matcher) { super.at_least_twice }
    subject(match_data) { matcher.match(actual) }

    it "doesn't match when the stub is called once" do
      dbl.test_method
      is_expected.to be_a(failed_match)
    end

    it "doesn't match when the stub isn't called" do
      is_expected.to be_a(failed_match)
    end

    it "matches when the stub is called twice" do
      2.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "matches when the stub is called more than twice" do
      3.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end
  end

  describe "#at_most_once" do
    let(matcher) { super.at_most_once }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called once" do
      dbl.test_method
      is_expected.to be_a(successful_match)
    end

    it "matches when the stub isn't called" do
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub is called more than once" do
      2.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end
  end

  describe "#at_most_twice" do
    let(matcher) { super.at_most_twice }
    subject(match_data) { matcher.match(actual) }

    it "matches when the stub is called once" do
      dbl.test_method
      is_expected.to be_a(successful_match)
    end

    it "matches when the stub isn't called" do
      is_expected.to be_a(successful_match)
    end

    it "matches when the stub is called twice" do
      2.times { dbl.test_method }
      is_expected.to be_a(successful_match)
    end

    it "doesn't match when the stub is called more than twice" do
      3.times { dbl.test_method }
      is_expected.to be_a(failed_match)
    end
  end
end
