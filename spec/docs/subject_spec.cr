require "../spec_helper"

Spectator.describe "subject" do
  subject(array1) { [1, 2, 3] }
  subject(array2) { [4, 5, 6] }

  it "has different elements" do
    expect(array1).to_not eq(subject) # array2 would also work here.
  end

  let(string) { "foobar" }

  it "isn't empty" do
    expect(string.empty?).to be_false
  end

  it "is six characters" do
    expect(string.size).to eq(6)
  end

  let(array) { [0, 1, 2] }

  it "modifies the array" do
    array[0] = 42
    expect(array).to eq([42, 1, 2])
  end

  it "doesn't carry across tests" do
    array[1] = 777
    expect(array).to eq([0, 777, 2])
  end
end
