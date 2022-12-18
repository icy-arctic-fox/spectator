require "../spec_helper"

module GitLabIssue51
  class Foo
    def call(str : String) : String?
      ""
    end

    def alt1_call(str : String) : String?
      nil
    end

    def alt2_call(str : String) : String?
      [str, nil].sample
    end
  end

  class Bar
    def call(a_foo) : Nil # Must add nil restriction here, otherwise a segfault occurs from returning the result of #alt2_call.
      a_foo.call("")
      a_foo.alt1_call("")
      a_foo.alt2_call("")
    end
  end
end

Spectator.describe GitLabIssue51::Bar do
  mock GitLabIssue51::Foo, call: "", alt1_call: "", alt2_call: ""

  let(:foo) { mock(GitLabIssue51::Foo) }
  subject(:call) { described_class.new.call(foo) }

  describe "#call" do
    it "invokes Foo#call" do
      call
      expect(foo).to have_received(:call)
    end

    it "invokes Foo#alt1_call" do
      call
      expect(foo).to have_received(:alt1_call)
    end

    it "invokes Foo#alt2_call" do
      call
      expect(foo).to have_received(:alt2_call)
    end

    describe "with an explicit return of nil" do
      it "should invoke Foo#call?" do
        allow(foo).to receive(:call).and_return(nil)
        call
        expect(foo).to have_received(:call)
      end

      it "invokes Foo#alt1_call" do
        allow(foo).to receive(:alt1_call).and_return(nil)
        call
        expect(foo).to have_received(:alt1_call)
      end

      it "invokes Foo#alt2_call" do
        allow(foo).to receive(:alt2_call).and_return(nil)
        call
        expect(foo).to have_received(:alt2_call)
      end
    end

    describe "with returns set in before_each for all calls" do
      before_each do
        allow(foo).to receive(:call).and_return(nil)
        allow(foo).to receive(:alt1_call).and_return(nil)
        allow(foo).to receive(:alt2_call).and_return(nil)
      end

      it "should invoke Foo#call?" do
        call
        expect(foo).to have_received(:call)
      end

      it "should invoke Foo#alt1_call?" do
        call
        expect(foo).to have_received(:alt1_call)
      end

      it "should invoke Foo#alt2_call?" do
        call
        expect(foo).to have_received(:alt2_call)
      end
    end

    describe "with returns set in before_each for alt calls only" do
      before_each do
        allow(foo).to receive(:alt1_call).and_return(nil)
        allow(foo).to receive(:alt2_call).and_return(nil)
      end

      it "invokes Foo#alt1_call" do
        call
        expect(foo).to have_received(:alt1_call)
      end

      it "invokes Foo#alt2_call" do
        call
        expect(foo).to have_received(:alt2_call)
      end
    end
  end
end
