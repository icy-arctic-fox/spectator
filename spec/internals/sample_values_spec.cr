require "../spec_helper"

private def add_sample_value(values : Spectator::Internals::SampleValues,
                             symbol : Symbol, name : String, value : T) forall T
  values.add(symbol, name, value)
end

private def add_sample_value(symbol, name, value : T) forall T
  add_sample_value(Spectator::Internals::SampleValues.empty, symbol, name, value)
end

private def add_sample_value(symbol, value : T) forall T
  add_sample_value(symbol, symbol.to_s, value)
end

describe Spectator::Internals::SampleValues do
  describe "#add" do
    it "creates a new set" do
      original = Spectator::Internals::SampleValues.empty
      new_set = original.add(:new, "new", 123)
      new_set.should_not eq(original)
    end

    it "adds a new value" do
      symbol = :new
      value = 123
      values = add_sample_value(symbol, value)
      values.get_value(symbol, typeof(value)).should eq(value)
    end
  end

  describe "#get_wrapper" do
    it "returns a wrapper for a value" do
      symbol = :new
      value = 123
      values = add_sample_value(symbol, value)
      wrapper = values.get_wrapper(symbol)
      wrapper.should be_a(Spectator::Internals::ValueWrapper)
    end

    it "returns the correct wrapper" do
      symbol = :new
      value = 123
      values = add_sample_value(symbol, value)
      wrapper = values.get_wrapper(symbol)
      wrapper.should be_a(Spectator::Internals::TypedValueWrapper(typeof(value)))
      wrapper.as(Spectator::Internals::TypedValueWrapper(typeof(value))).value.should eq(value)
    end

    context "with multiple values" do
      it "returns the expected value" do
        symbols = {
          one:   123,
          two:   456,
          three: 789,
        }
        values = Spectator::Internals::SampleValues.empty
        symbols.each do |symbol, number|
          values = add_sample_value(values, symbol, symbol.to_s, number)
        end
        selected_symbol = :one
        selected_number = symbols[selected_symbol]
        wrapper = values.get_wrapper(selected_symbol)
        wrapper.should be_a(Spectator::Internals::TypedValueWrapper(typeof(selected_number)))
        wrapper.as(Spectator::Internals::TypedValueWrapper(typeof(selected_number))).value.should eq(selected_number)
      end
    end
  end

  describe "#get_value" do
    it "returns a value" do
      symbol = :new
      value = 123
      values = add_sample_value(symbol, value)
      values.get_value(symbol, typeof(value)).should eq(value)
    end

    context "with multiple values" do
      it "returns the expected value" do
        symbols = {
          one:   123,
          two:   456,
          three: 789,
        }
        values = Spectator::Internals::SampleValues.empty
        symbols.each do |symbol, number|
          values = add_sample_value(values, symbol, symbol.to_s, number)
        end
        selected_symbol = :one
        selected_number = symbols[selected_symbol]
        value = values.get_value(selected_symbol, typeof(selected_number))
        value.should eq(selected_number)
      end
    end
  end

  describe "#each" do
    it "yields each entry" do
      symbols = {
        one:   123,
        two:   456,
        three: 789,
      }
      values = Spectator::Internals::SampleValues.empty
      symbols.each do |symbol, number|
        values = add_sample_value(values, symbol, symbol.to_s, number)
      end

      size = 0
      values.each do |entry|
        size += 1
        symbols.keys.map(&.to_s).should contain(entry.name)
      end
      size.should eq(symbols.size)
    end
  end
end
