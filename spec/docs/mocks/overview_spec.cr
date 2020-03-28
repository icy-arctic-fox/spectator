require "../../spec_helper"

Spectator.describe "Doubles" do
  double :my_double do
    stub answer { 42 }
  end

  specify "the answer to everything" do
    dbl = double(:my_double)
    expect(dbl.answer).to eq(42)
  end
end

class MyType
  def answer
    123
  end
end

Spectator.describe "Mocks" do
  mock MyType do
    stub answer { 42 }
  end

  specify "the answer to everything" do
    m = MyType.new
    expect(m.answer).to eq(42)
  end
end
Spectator.describe "Mocks and doubles" do
  double :my_double do
    stub answer : Int32 # Return type required, otherwise nil is assumed.
  end

  specify "the answer to everything" do
    dbl = double(:my_double)
    allow(dbl).to receive(:answer).and_return(42)
    expect(dbl.answer).to eq(42)
  end
end
