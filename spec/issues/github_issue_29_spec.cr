require "../spec_helper"

Spectator.describe "GitHub Issue #29" do
  class SomeClass
    def goodbye
      exit 0
    end
  end

  # mock SomeClass do
  #   inject_stub abstract def exit(code)
  # end

  describe SomeClass do
    xit "captures exit", pending: "Mock redesign" do
      expect(subject).to receive(:exit).with(0)
      subject.goodbye
    end
  end

  describe "class method" do
    class Foo
      def self.test
        exit 0
      end
    end

    # mock Foo do
    #   inject_stub abstract def self.exit(code)
    # end

    subject { Foo }

    xit "must capture exit", pending: "Mock redesign" do
      expect(subject).to receive(:exit).with(0)

      subject.test
    end
  end
end
