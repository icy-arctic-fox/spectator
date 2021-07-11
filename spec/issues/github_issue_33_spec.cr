require "../spec_helper"

Spectator.describe "GitHub Issue #33" do
  class Test
    def method2
    end

    def method1
      method2
    end
  end

  mock Test do
    stub method2
  end

  describe Test do
    describe "#method1" do
      it do
        expect(subject).to receive(:method2)

        subject.method1
      end
    end
  end
end
