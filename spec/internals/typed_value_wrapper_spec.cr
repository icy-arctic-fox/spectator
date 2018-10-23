require "../spec_helper"

describe Spectator::Internals::TypedValueWrapper do
  describe "#value" do
    it "returns the expected value" do
      value = 12345
      wrapper = Spectator::Internals::TypedValueWrapper.new(value)
      wrapper.value.should eq(value)
    end
  end

  it "can be cast for storage" do
    value = 12345
    wrapper = Spectator::Internals::TypedValueWrapper.new(value).as(Spectator::Internals::ValueWrapper)
    typed = wrapper.as(Spectator::Internals::TypedValueWrapper(typeof(value)))
    typed.value.should eq(value)
  end
end
