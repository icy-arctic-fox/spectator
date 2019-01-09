module Spectator
  class ExampleConditions
    def self.empty
      new(
        [] of ->,
        [] of ->
      )
    end

    def initialize(
      @pre_conditions : Array(->),
      @post_conditions : Array(->)
    )
    end

    def run_pre_conditions
      @pre_conditions.each &.call
    end

    def run_post_conditions
      @post_conditions.each &.call
    end
  end
end
