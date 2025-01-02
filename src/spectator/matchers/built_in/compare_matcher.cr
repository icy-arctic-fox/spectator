require "../matchable"

module Spectator::Matchers::BuiltIn
  struct CompareMatcher(T)
    include Matchable

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

    def matches?(actual_value)
      case @relation
      in .less?             then actual_value < @expected_value
      in .less_or_equal?    then actual_value <= @expected_value
      in .equal?            then actual_value == @expected_value
      in .greater_or_equal? then actual_value >= @expected_value
      in .greater?          then actual_value > @expected_value
      in .not_equal?        then actual_value != @expected_value
      end
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value)
      printer << " to be " << @relation << ' ' << description_of(@expected_value)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value)
      printer << " to be " << @relation.negate << ' ' << description_of(@expected_value)
    end

    def to_s(io : IO) : Nil
      io << "be " << @relation << ' ' << @expected_value
    end

    def self.<(other : T)
      new(other, :less)
    end

    def self.<=(other : T)
      new(other, :less_or_equal)
    end

    def self.==(other : T)
      new(other, :equal)
    end

    def self.>=(other : T)
      new(other, :greater_or_equal)
    end

    def self.>(other : T)
      new(other, :greater)
    end

    def self.!=(other : T)
      new(other, :not_equal)
    end
  end
end
