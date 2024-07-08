# require "./built_in/*"

module Spectator::Matchers
  module BuiltIn
    def all(matcher)
    end

    def be
    end

    def be(expected)
    end

    def be_a(type)
    end

    def be_an(type)
      be_a(type)
    end

    def be_kind_of(type)
      be_a(type)
    end

    def be_a_kind_of(type)
      be_a(type)
    end

    def be_between(min, max)
    end

    def be_blank
    end

    def be_close(expected, delta)
    end

    def be_close_to(expected, digits)
    end

    def be_empty
    end

    def be_false
    end

    def be_falsey
    end

    def be_falsy
      be_falsey
    end

    def be_in(range_or_set)
    end

    def be_infinite
    end

    def be_instance_of(type)
    end

    def be_a_instance_of(type)
      be_instance_of(type)
    end

    def be_an_instance_of(type)
      be_instance_of(type)
    end

    def be_nan
    end

    def be_negative
    end

    def be_nil
    end

    def be_positive
    end

    def be_present
    end

    def be_true
    end

    def be_truthy
    end

    def be_within(delta) # of(expected)
    end

    def be_within(range : Range)
    end

    def be_zero
    end

    def change(&block) # by(change) / from(from) / to(to)
    end

    def contain(expected)
    end

    def contain_exactly(*values)
    end

    def cover(*value)
    end

    def end_with(expected)
    end

    def eq(value)
    end

    def equal(value)
      eq(value)
    end

    def expect_raises
    end

    def have_attributes(**attributes)
    end

    def have_index(value : Int)
    end

    def have_key(value : T)
    end

    def have_size(value)
    end

    def have_value(value : T)
    end

    def match(value) # =~
    end

    def match_array(array)
    end

    def raise_error
    end

    def respond_to
    end

    def satisfy(&block)
    end

    def start_with(expected)
    end
  end
end
