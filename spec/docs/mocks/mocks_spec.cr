require "../../spec_helper"

class Phonebook
  def find(name)
    # Some expensive lookup call.
    "+18005554321"
  end
end

class Resolver
  def initialize(@phonebook : Phonebook)
  end

  def find(name)
    @phonebook.find(name)
  end
end

Spectator.describe Resolver do
  mock Phonebook do
    stub find(name)
  end

  describe "#find" do
    it "can find number" do
      pb = Phonebook.new
      allow(pb).to receive(find).and_return("+18005551234")
      resolver = Resolver.new(pb)
      expect(resolver.find("Bob")).to eq("+18005551234")
    end
  end
end
