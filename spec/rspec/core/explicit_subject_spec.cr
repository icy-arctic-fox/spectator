require "../../spec_helper"

# Examples taken from:
# https://relishapp.com/rspec/rspec-core/v/3-8/docs/subject/explicit-subject
# and modified to fit Spectator and Crystal.
Spectator.describe "Explicit Subject" do
  context "A `subject` can be defined and used in the top level group scope" do
    describe Array(Int32) do # TODO: Multiple arguments to describe/context.
      subject { [1, 2, 3] }

      it "has the prescribed elements" do
        expect(subject).to eq([1, 2, 3])
      end
    end
  end

  context "The `subject` define in an outer group is available to inner groups" do
    describe Array(Int32) do
      subject { [1, 2, 3] }

      describe "has some elements" do
        it "which are the prescribed elements" do
          expect(subject).to eq([1, 2, 3])
        end
      end
    end
  end

  context "The `subject` is memoized within an example but not across examples" do
    describe Array(Int32) do
      # Changed to class variable to get around compiler error/crash.
      # Unhandled exception: Negative argument (ArgumentError)
      @@element_list = [1, 2, 3]

      subject { @@element_list.pop }

      it "is memoized across calls (i.e. the block is invoked once)" do
        expect do
          3.times { subject }
        end.to change { @@element_list }.from([1, 2, 3]).to([1, 2])
        expect(subject).to eq(3)
      end

      it "is not memoized across examples" do
        expect { subject }.to change { @@element_list }.from([1, 2]).to([1])
        expect(subject).to eq(2)
      end
    end
  end

  context "The `subject` is available in `before` blocks" do
    describe Array(Int32) do # TODO: Multiple arguments to describe/context.
      subject { [] of Int32 }

      before { subject.push(1, 2, 3) }

      it "has the prescribed elements" do
        expect(subject).to eq([1, 2, 3])
      end
    end
  end

  context "Helper methods can be invoked from a `subject` definition block" do
    describe Array(Int32) do # TODO: Multiple arguments to describe/context.
      def prepared_array
        [1, 2, 3]
      end

      subject { prepared_array }

      it "has the prescribed elements" do
        expect(subject).to eq([1, 2, 3])
      end
    end
  end

  context "Use the `subject!` bang method to call the definition block before the example" do
    describe "eager loading with subject!" do
      subject! { element_list.push(99) }

      let(:element_list) { [1, 2, 3] }

      it "calls the definition block before the example" do
        element_list.push(5)
        expect(element_list).to eq([1, 2, 3, 99, 5])
      end
    end
  end

  context "Use `subject(:name)` to define a memoized helper method" do
    # Globals not supported, using class variable instead.
    @@count = 0

    describe "named subject" do
      subject(:global_count) { @@count += 1 }

      it "is memoized across calls (i.e. the block is invoked once)" do
        expect do
          2.times { global_count }
        end.not_to change { global_count }.from(1)
      end

      it "is not cached across examples" do
        expect(global_count).to eq(2)
      end

      it "is still available using the subject method" do
        expect(subject).to eq(3)
      end

      it "works with the one-liner syntax" do
        is_expected.to eq(4)
      end

      it "the subject and named helpers return the same object" do
        expect(global_count).to be(subject)
      end

      it "is set to the block return value (i.e. the global $count)" do
        expect(global_count).to be(@@count)
      end
    end
  end

  context "Use `subject!(:name)` to define a helper method called before the example" do
    describe "eager loading using a named subject!" do
      subject!(:updated_list) { element_list.push(99) }

      let(:element_list) { [1, 2, 3] }

      it "calls the definition block before the example" do
        element_list.push(5)
        expect(element_list).to eq([1, 2, 3, 99, 5])
        expect(updated_list).to be(element_list)
      end
    end
  end
end
