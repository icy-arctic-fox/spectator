require "../spec_helper"

Spectator.describe "GitHub Issue #48" do
  class Test
    def return_this(thing : T) : T forall T
      thing
    end

    def map(thing : T, & : T -> U) : U forall T, U
      yield thing
    end

    def make_nilable(thing : T) : T? forall T
      thing.as(T?)
    end
  end

  mock Test, make_nilable: nil

  let(fake) { mock(Test) }

  it "handles free variables" do
    allow(fake).to receive(:return_this).and_return("different")
    expect(fake.return_this("test")).to eq("different")
  end

  it "raises on type cast error with free variables" do
    allow(fake).to receive(:return_this).and_return(42)
    expect { fake.return_this("test") }.to raise_error(TypeCastError, /String/)
  end

  it "handles free variables with a block" do
    allow(fake).to receive(:map).and_return("stub")
    expect(fake.map(:mapped, &.to_s)).to eq("stub")
  end

  it "raises on type cast error with a block and free variables" do
    allow(fake).to receive(:map).and_return(42)
    expect { fake.map(:mapped, &.to_s) }.to raise_error(TypeCastError, /String/)
  end

  it "handles nilable free variables" do
    fake = mock(Test)
    expect(fake.make_nilable("foo")).to be_nil
  end
end
