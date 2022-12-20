require "../spec_helper"

Spectator.describe "Expect Type", :smoke do
  context "with expect syntax" do
    it "ensures a type is cast" do
      value = 42.as(String | Int32)
      expect(value).to be_a(String | Int32)
      expect(value).to compile_as(String | Int32)
      value = expect(value).to be_a(Int32)
      expect(value).to eq(42)
      expect(value).to be_a(Int32)
      expect(value).to compile_as(Int32)
      expect(value).to_not respond_to(:downcase)
    end

    it "ensures a type is not nil" do
      value = 42.as(Int32?)
      expect(value).to be_a(Int32?)
      expect(value).to compile_as(Int32?)
      value = expect(value).to_not be_nil
      expect(value).to eq(42)
      expect(value).to be_a(Int32)
      expect(value).to compile_as(Int32)
      expect { value.not_nil! }.to_not raise_error(NilAssertionError)
    end

    it "removes types from a union" do
      value = 42.as(String | Int32)
      expect(value).to be_a(String | Int32)
      expect(value).to compile_as(String | Int32)
      value = expect(value).to_not be_a(String)
      expect(value).to eq(42)
      expect(value).to be_a(Int32)
      expect(value).to compile_as(Int32)
      expect(value).to_not respond_to(:downcase)
    end
  end

  context "with should syntax" do
    it "ensures a type is cast" do
      value = 42.as(String | Int32)
      value.should be_a(String | Int32)
      value = value.should be_a(Int32)
      value.should eq(42)
      value.should be_a(Int32)
      value.should compile_as(Int32)
      value.should_not respond_to(:downcase)
    end

    it "ensures a type is not nil" do
      value = 42.as(Int32?)
      value.should be_a(Int32?)
      value = value.should_not be_nil
      value.should eq(42)
      value.should be_a(Int32)
      value.should compile_as(Int32)
      expect { value.not_nil! }.to_not raise_error(NilAssertionError)
    end

    it "removes types from a union" do
      value = 42.as(String | Int32)
      value.should be_a(String | Int32)
      value = value.should_not be_a(String)
      value.should eq(42)
      value.should be_a(Int32)
      value.should compile_as(Int32)
      value.should_not respond_to(:downcase)
    end
  end
end
