require "../core/location_range"

module Spectator::Matchers
  struct MatchData
    alias Field = {String, String}

    getter? success : Bool
    getter? negated : Bool
    getter! message : String
    getter fields : Array(Field)

    def initialize(@success : Bool, @negated : Bool, *,
                   @message : String? = nil,
                   @fields = [] of Field)
    end

    def self.pass(*, negated : Bool = false) : self
      new(true, negated)
    end

    def self.fail(*,
                  negated : Bool = false,
                  message : String? = nil,
                  fields : Enumerable(Field) = [] of Field) : self
      new(false, negated, message: message, fields: fields.to_a)
    end

    def each_field(&block : Field ->) : Nil
      @fields.each { |field| yield field }
    end
  end
end
