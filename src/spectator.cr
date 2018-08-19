require "./spectator/*"

def expect(actual : T) forall T
  pp actual
end

# TODO: Write documentation for `Spectator`
module Spectator
  VERSION = "0.1.0"

  @@top_level_groups = [] of ExampleGroup

  def self.describe(type : T.class) : Nil forall T
    group = DSL.new(type.to_s)
    with group yield
    @@top_level_groups << group._spec_build
  end

  at_exit do
    @@top_level_groups.each do |group|
      group.examples.each do |example|
        example.run
      end
    end
  end
end
