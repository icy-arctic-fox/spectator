module Spectator::Matchers::BuiltIn
  struct CompareMatcher(T)
    enum Relation
      Less
      LessOrEqual
      Equal
      GreaterOrEqual
      Greater
      NotEqual

      def to_s(io : IO) : Nil
        io << case self
        in .less?             then "less than"
        in .less_or_equal?    then "less than or equal to"
        in .equal?            then "equal to"
        in .greater_or_equal? then "greater than or equal to"
        in .greater?          then "greater than"
        in .not_equal?        then "not equal to"
        end
      end

      def operator : String
        case self
        in .less?             then "<"
        in .less_or_equal?    then "<="
        in .equal?            then "=="
        in .greater_or_equal? then ">="
        in .greater?          then ">"
        in .not_equal?        then "!="
        end
      end

      def negate : self
        case self
        in .less?             then GreaterOrEqual
        in .less_or_equal?    then Greater
        in .equal?            then NotEqual
        in .greater_or_equal? then Less
        in .greater?          then LessOrEqual
        in .not_equal?        then Equal
        end
      end
    end

    def initialize(@expected_value : T, @relation : Relation)
    end

    def matches?(actual_value) : Bool
      case @relation
      in .less?             then actual_value < @expected_value
      in .less_or_equal?    then actual_value <= @expected_value
      in .equal?            then actual_value == @expected_value
      in .greater_or_equal? then actual_value >= @expected_value
      in .greater?          then actual_value > @expected_value
      in .not_equal?        then actual_value != @expected_value
      end
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be #{@relation} #{@expected_value.pretty_inspect}"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be #{@relation.negate} #{@expected_value.pretty_inspect}"
    end

    def self.<(expected_value : T) : self
      new(expected_value, :less)
    end

    def self.<=(expected_value : T) : self
      new(expected_value, :less_or_equal)
    end

    def self.==(expected_value : T) : self
      new(expected_value, :equal)
    end

    def self.>=(expected_value : T) : self
      new(expected_value, :greater_or_equal)
    end

    def self.>(expected_value : T) : self
      new(expected_value, :greater)
    end

    def self.!=(expected_value : T) : self
      new(expected_value, :not_equal)
    end
  end
end
