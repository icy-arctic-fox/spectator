require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/predicate-matchers
# and modified to fit Spectator and Crystal.
Spectator.describe "Predicate matchers" do
  context "should be_zero (based on Int#zero?)" do
    describe 0 do
      it { is_expected.to be_zero }
    end

    describe 7 do
      # deliberate failure
      it_fails { is_expected.to be_zero }
    end
  end

  context "should_not be_empty (based on Array#empty?)" do
    describe [1, 2, 3] do
      it { is_expected.not_to be_empty }
    end

    describe [] of Int32 do
      # deliberate failure
      it_fails { is_expected.not_to be_empty }
    end
  end

  context "should have_key (based on Hash#has_key?)" do
    describe Hash do
      subject { {:foo => 7} }

      it { is_expected.to have_key(:foo) }

      # deliberate failure
      it_fails { is_expected.to have_key(:bar) }
    end
  end

  context "should_not have_all_string_keys (based on custom #has_all_string_keys? method)" do
    class ::Hash(K, V)
      def has_all_string_keys?
        keys.all? { |k| String === k }
      end
    end

    describe Hash do
      context "with symbol keys" do
        subject { {:foo => 7, :bar => 5} }

        it { is_expected.not_to have_all_string_keys }
      end

      context "with string keys" do
        subject { {"foo" => 7, "bar" => 5} }

        # deliberate failure
        it_fails { is_expected.not_to have_all_string_keys }
      end
    end
  end

  context "matcher arguments are passed on to the predicate method" do
    struct ::Int
      def multiple_of?(x)
        (self % x).zero?
      end
    end

    describe 12 do
      it { is_expected.to be_multiple_of(3) }
      it { is_expected.not_to be_multiple_of(7) }

      # deliberate failures
      it_fails { is_expected.not_to be_multiple_of(4) }
      it_fails { is_expected.to be_multiple_of(5) }
    end
  end

  # The examples using private methods cause a compilation error in Crystal, and can't be used here.
end
