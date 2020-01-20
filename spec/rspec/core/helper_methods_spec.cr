require "../../spec_helper"

Spectator.describe "Arbitrary helper methods" do
  context "Use a method define in the same group" do
    describe "an example" do
      def help
        :available
      end

      it "has access to methods define in its group" do
        expect(help).to be(:available)
      end
    end
  end

  context "Use a method defined in a parent group" do
    describe "an example" do
      def help
        :available
      end

      describe "in a nested group" do
        it "has access to methods defined in its parent group" do
          expect(help).to be(:available)
        end
      end
    end
  end
end
