require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-expectations/v/3-8/docs/built-in-matchers/type-matchers
# and modified to fit Spectator and Crystal.
Spectator.describe "Type matchers" do
  context "be_(a_)kind_of matcher" do
    # The docs use Float as an example.
    # This doesn't work with the Crystal compiler,
    # so a custom hierarchy is used instead.
    # "Error: can't use Number as generic type argument yet, use a more specific type"

    module MyModule; end

    class Base; end

    class Derived < Base
      include MyModule
    end

    describe Derived do
      # the actual class
      it { is_expected.to be_kind_of(Derived) }
      it { is_expected.to be_a_kind_of(Derived) }
      it { is_expected.to be_a(Derived) }

      # the superclass
      it { is_expected.to be_kind_of(Base) }
      it { is_expected.to be_a_kind_of(Base) }
      it { is_expected.to be_an(Base) }

      # an included module
      it { is_expected.to be_kind_of(MyModule) }
      it { is_expected.to be_a_kind_of(MyModule) }
      it { is_expected.to be_a(MyModule) }

      # negative passing case
      it { is_expected.not_to be_kind_of(String) }
      it { is_expected.not_to be_a_kind_of(String) }
      it { is_expected.not_to be_a(String) }

      # deliberate failures
      it_fails { is_expected.not_to be_kind_of(Derived) }
      it_fails { is_expected.not_to be_a_kind_of(Derived) }
      it_fails { is_expected.not_to be_a(Derived) }
      it_fails { is_expected.not_to be_kind_of(Base) }
      it_fails { is_expected.not_to be_a_kind_of(Base) }
      it_fails { is_expected.not_to be_an(Base) }
      it_fails { is_expected.not_to be_kind_of(MyModule) }
      it_fails { is_expected.not_to be_a_kind_of(MyModule) }
      it_fails { is_expected.not_to be_a(MyModule) }
      it_fails { is_expected.to be_kind_of(String) }
      it_fails { is_expected.to be_a_kind_of(String) }
      it_fails { is_expected.to be_a(String) }
    end

    context "be_(an_)instance_of matcher" do
      # The docs use Float as an example.
      # This doesn't work with the Crystal compiler,
      # so a custom hierarchy is used instead.
      # "Error: can't use Number as generic type argument yet, use a more specific type"

      module MyModule; end

      class Base; end

      class Derived < Base
        include MyModule
      end

      describe Derived do
        # the actual class
        it { is_expected.to be_instance_of(Derived) }
        it { is_expected.to be_an_instance_of(Derived) }

        # the superclass
        it { is_expected.not_to be_instance_of(Base) }
        it { is_expected.not_to be_an_instance_of(Base) }

        # an included module
        it { is_expected.not_to be_instance_of(MyModule) }
        it { is_expected.not_to be_an_instance_of(MyModule) }

        # another class with no relation to the subject's hierarchy
        it { is_expected.not_to be_instance_of(String) }
        it { is_expected.not_to be_an_instance_of(String) }

        # deliberate failures
        it_fails { is_expected.not_to be_instance_of(Derived) }
        it_fails { is_expected.not_to be_an_instance_of(Derived) }
        it_fails { is_expected.to be_instance_of(Base) }
        it_fails { is_expected.to be_an_instance_of(Base) }
        it_fails { is_expected.to be_instance_of(MyModule) }
        it_fails { is_expected.to be_an_instance_of(MyModule) }
        it_fails { is_expected.to be_instance_of(String) }
        it_fails { is_expected.to be_an_instance_of(String) }
      end
    end
  end
end
