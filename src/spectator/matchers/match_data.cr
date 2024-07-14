module Spectator::Matchers
  alias MatchDataField = {String, String} | {Symbol, String} | String

  struct MatchData
    getter? success : Bool
    getter? negated : Bool

    def initialize(@success : Bool, @negated : Bool, @fields : Array(Field))
    end

    def each_field(&block : MatchDataField ->) : Nil
      @fields.each { |field| yield field }
    end
  end
end
