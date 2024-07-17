require "../core/location_range"

module Spectator::Matchers
  alias MatchDataField = {String, String} | {Symbol, String} | String

  struct MatchData
    getter? success : Bool
    getter? negated : Bool
    getter! message : String
    getter fields : Array(MatchDataField)

    def initialize(@success : Bool, @negated : Bool, *,
                   @message : String? = nil,
                   @fields = [] of MatchDataField)
    end

    def each_field(&block : MatchDataField ->) : Nil
      @fields.each { |field| yield field }
    end
  end
end
