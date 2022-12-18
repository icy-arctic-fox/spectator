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

    def itself : self
      self
    end

    def itself? : self?
      self.as(self?)
    end

    def generic(thing : T) : Array(T) forall T
      Array.new(100) { thing }
    end

    def union : Int32 | String
      42.as(Int32 | String)
    end

    def capture(&block : -> T) forall T
      block
    end

    def capture(thing : T, &block : T -> T) forall T
      block.call(thing)
      block
    end

    def range(r : Range)
      r
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
    expect(fake.make_nilable("foo")).to be_nil
  end

  it "handles 'self' return type" do
    not_self = mock(Test)
    allow(fake).to receive(:itself).and_return(not_self)
    expect(fake.itself).to be(not_self)
  end

  it "raises on type cast error with 'self' return type" do
    allow(fake).to receive(:itself).and_return(42)
    expect { fake.itself }.to raise_error(TypeCastError, /#{class_mock(Test)}/)
  end

  it "handles nilable 'self' return type" do
    not_self = mock(Test)
    allow(fake).to receive(:itself?).and_return(not_self)
    expect(fake.itself?).to be(not_self)
  end

  it "handles generic return type" do
    allow(fake).to receive(:generic).and_return([42])
    expect(fake.generic(42)).to eq([42])
  end

  it "raises on type cast error with generic return type" do
    allow(fake).to receive(:generic).and_return("test")
    expect { fake.generic(42) }.to raise_error(TypeCastError, /Array\(Int32\)/)
  end

  it "handles union return types" do
    allow(fake).to receive(:union).and_return("test")
    expect(fake.union).to eq("test")
  end

  it "raises on type cast error with union return type" do
    allow(fake).to receive(:union).and_return(:test)
    expect { fake.union }.to raise_error(TypeCastError, /Symbol/)
  end

  it "handles captured blocks" do
    proc = ->{}
    allow(fake).to receive(:capture).and_return(proc)
    expect(fake.capture { nil }).to be(proc)
  end

  it "raises on type cast error with captured blocks" do
    proc = ->{ 42 }
    allow(fake).to receive(:capture).and_return(proc)
    expect { fake.capture { "other" } }.to raise_error(TypeCastError, /Proc\(String\)/)
  end

  it "handles captured blocks with arguments" do
    proc = ->(x : Int32) { x * 2 }
    allow(fake).to receive(:capture).and_return(proc)
    expect(fake.capture(5) { 5 }).to be(proc)
  end

  it "handles range comparisons against non-comparable types" do
    range = 1..10
    allow(fake).to receive(:range).and_return(range)
    expect(fake.range(1..3)).to eq(range)
  end
end
