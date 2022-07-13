require "../spec_helper"

Spectator.describe "GitHub Issue #32" do
  module TestFoo
    class TestClass
      def initialize
      end

      # the method we are testing
      def self.test
        new().test
      end

      # the method we want to ensure gets called
      def test
      end
    end
  end

  let(test_class) { TestFoo::TestClass }
  let(test_instance) { test_class.new }

  describe "something else" do
    inject_mock TestFoo::TestClass

    it "must test when new is called" do
      expect(test_class).to receive(:new).with(no_args).and_return(test_instance)
      expect(test_instance).to receive(:test)
      expect(test_class.new).to be(test_instance)

      test_class.test
    end
  end
end
