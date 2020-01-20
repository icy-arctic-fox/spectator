require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-core/v/3-8/docs/subject/implicitly-defined-subject
# and modified to fit Spectator and Crystal.
Spectator.describe "Implicitly defined subject" do
  context "`subject` exposed in top-level group" do
    describe Array(String) do
      it "should be empty when first created" do
        expect(subject).to be_empty
      end
    end
  end

  context "`subject` in a nested group" do
    describe Array(String) do
      describe "when first created" do
        it "should  be empty" do
          expect(subject).to be_empty
        end
      end
    end
  end

  context "`subject` in a nested group with a different class (innermost wins)" do
    class ArrayWithOneElement < Array(String)
      def initialize(*_args)
        super
        unshift "first element"
      end
    end

    describe Array(String) do
      describe ArrayWithOneElement do
        context "referenced as subject" do
          it "contains one element" do
            expect(subject).to contain("first element")
          end
        end
      end
    end
  end
end
