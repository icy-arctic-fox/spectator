require "./spec_helper"

# This is a meta test that ensures specs can be compiled and run at runtime.
# The purpose of this is to report an error if this process fails.
# Other tests will fail, but display a different name/description of the test.
# This clearly indicates that runtime testing failed.
#
# Runtime compilation is used to get output of tests as well as check syntax.
# Some specs are too complex to be ran normally.
# Additionally, this allows examples to easily check specific failure cases.
# Plus, it makes testing user-reported issues easy.
Spectator.describe "Runtime compilation" do
  given_example passing_example do
    it "does something" do
      expect(true).to be_true
    end
  end

  it "can compile and retrieve the result of an example" do
    expect(passing_example).to be_successful
  end

  given_example failing_example do
    it "does something" do
      expect(true).to be_false
    end
  end

  it "detects failed examples" do
    expect(failing_example).to be_failure
  end

  given_example malformed_example do
    it "does something" do
      asdf
    end
  end

  it "raises on compilation errors" do
    expect { malformed_example }.to raise_error(/compilation/i)
  end
end
