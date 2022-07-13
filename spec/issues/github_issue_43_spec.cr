require "../spec_helper"

class Person
  def initialize(@dog = Dog.new)
  end

  def pet
    @dog.pet
  end

  def pet_more
    @dog.pet(5)
  end
end

class Dog
  def initialize
  end

  def pet(times = 2)
    "woof" * times
  end
end

Spectator.describe Person do
  mock Dog

  describe "#pet" do
    it "pets the persons dog" do
      dog = mock(Dog)
      person = Person.new(dog)
      allow(dog).to receive(pet()).and_return("woof")

      person.pet

      expect(dog).to have_received(pet()).with(2)
    end
  end

  describe "#pet_more" do
    it "pets the persons dog alot" do
      dog = mock(Dog)
      person = Person.new(dog)
      allow(dog).to receive(pet()).and_return("woof")

      person.pet_more

      expect(dog).to have_received(pet()).with(5)
    end
  end
end
