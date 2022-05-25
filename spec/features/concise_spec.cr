require "../spec_helper"

Spectator.describe Spectator, :smoke do
  context "consice syntax" do
    describe "provided group with a single assignment" do
      provided x = 42 do
        expect(x).to eq(42)
      end
    end

    describe "provided group with multiple assignments" do
      provided x = 42, y = 123 do
        expect(x).to eq(42)
        expect(y).to eq(123)
      end
    end

    describe "provided group with a single named argument" do
      provided x: 42 do
        expect(x).to eq(42)
      end
    end

    describe "provided group with multiple named arguments" do
      provided x: 42, y: 123 do
        expect(x).to eq(42)
        expect(y).to eq(123)
      end
    end

    describe "provided group with mix of assignments and named arguments" do
      provided x = 42, y: 123 do
        expect(x).to eq(42)
        expect(y).to eq(123)
      end

      provided x = 42, y = 123, z: 0, foo: "bar" do
        expect(x).to eq(42)
        expect(y).to eq(123)
        expect(z).to eq(0)
        expect(foo).to eq("bar")
      end
    end

    describe "provided group with references to other arguments" do
      let(foo) { "bar" }

      provided x = 3, y: x * 5, baz: foo.sub('r', 'z') do
        expect(x).to eq(3)
        expect(y).to eq(15)
        expect(baz).to eq("baz")
      end
    end
  end
end
