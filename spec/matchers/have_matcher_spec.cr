require "../spec_helper"

describe Spectator::Matchers::HaveMatcher do
  describe "#match?" do
    context "with a String" do
      context "one argument" do
        context "against a matching string" do
          it "is true" do
            value = "foobarbaz"
            search = "bar"
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              value = "foobar"
              search = "foo"
              partial = Spectator::Expectations::ValueExpectationPartial.new(value)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              value = "foobar"
              search = "bar"
              partial = Spectator::Expectations::ValueExpectationPartial.new(value)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a different string" do
          it "is false" do
            value = "foobar"
            search = "baz"
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end

        context "against a matching character" do
          it "is true" do
            value = "foobar"
            search = 'o'
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              value = "foobar"
              search = 'f'
              partial = Spectator::Expectations::ValueExpectationPartial.new(value)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              value = "foobar"
              search = 'r'
              partial = Spectator::Expectations::ValueExpectationPartial.new(value)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a different character" do
          it "is false" do
            value = "foobar"
            search = 'z'
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end
      end

      context "multiple arguments" do
        context "against matching strings" do
          it "is true" do
            value = "foobarbaz"
            search = {"foo", "bar", "baz"}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one matching string" do
          it "is false" do
            value = "foobarbaz"
            search = {"foo", "qux"}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no matching strings" do
          it "is false" do
            value = "foobar"
            search = {"baz", "qux"}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against matching characters" do
          it "is true" do
            value = "foobarbaz"
            search = {'f', 'b', 'z'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one matching character" do
          it "is false" do
            value = "foobarbaz"
            search = {'f', 'c', 'd'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no matching characters" do
          it "is false" do
            value = "foobarbaz"
            search = {'c', 'd', 'e'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against a matching string and character" do
          it "is true" do
            value = "foobarbaz"
            search = {"foo", 'z'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against a matching string and non-matching character" do
          it "is false" do
            value = "foobarbaz"
            search = {"foo", 'c'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against a non-matching string and matching character" do
          it "is false" do
            value = "foobarbaz"
            search = {"qux", 'f'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against a non-matching string and character" do
          it "is false" do
            value = "foobarbaz"
            search = {"qux", 'c'}
            partial = Spectator::Expectations::ValueExpectationPartial.new(value)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end
      end
    end

    context "with an Enumberable" do
      context "one argument" do
        context "against an equal value" do
          it "is true" do
            array = %i[a b c]
            search = :b
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              array = %i[a b c]
              search = :a
              partial = Spectator::Expectations::ValueExpectationPartial.new(array)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              array = %i[a b c]
              search = :c
              partial = Spectator::Expectations::ValueExpectationPartial.new(array)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a different value" do
          it "is false" do
            array = %i[a b c]
            search = :z
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end

        context "against a matching type" do
          it "is true" do
            array = %i[a b c]
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new({Symbol})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              array = [:a, 1, 2]
              partial = Spectator::Expectations::ValueExpectationPartial.new(array)
              matcher = Spectator::Matchers::HaveMatcher.new({Symbol})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              array = [0, 1, :c]
              partial = Spectator::Expectations::ValueExpectationPartial.new(array)
              matcher = Spectator::Matchers::HaveMatcher.new({Symbol})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a non-matching type" do
          it "is false" do
            array = %i[a b c]
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new({Int32})
            matcher.match?(partial).should be_false
          end
        end

        context "against a matching regex" do
          it "is true" do
            array = %w[FOO BAR BAZ]
            search = /bar/i
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              array = %w[FOO BAR BAZ]
              search = /foo/i
              partial = Spectator::Expectations::ValueExpectationPartial.new(array)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              array = %w[FOO BAR BAZ]
              search = /baz/i
              partial = Spectator::Expectations::ValueExpectationPartial.new(array)
              matcher = Spectator::Matchers::HaveMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a non-matching regex" do
          it "is false" do
            array = %w[FOO BAR BAZ]
            search = /qux/i
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end
      end

      context "multiple arguments" do
        context "against equal values" do
          it "is true" do
            array = %i[a b c]
            search = {:a, :b}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end

          context "matching type" do
            context "matching regex" do
              it "is true" do
                array = [:a, 42, "FOO"]
                search = {:a, Int32, /foo/i}
                partial = Spectator::Expectations::ValueExpectationPartial.new(array)
                matcher = Spectator::Matchers::HaveMatcher.new(search)
                matcher.match?(partial).should be_true
              end
            end

            context "non-matching regex" do
              it "is false" do
                array = [:a, 42, "FOO"]
                search = {:a, Int32, /bar/i}
                partial = Spectator::Expectations::ValueExpectationPartial.new(array)
                matcher = Spectator::Matchers::HaveMatcher.new(search)
                matcher.match?(partial).should be_false
              end
            end
          end

          context "non-matching type" do
            context "matching regex" do
              it "is false" do
                array = [:a, 42, "FOO"]
                search = {:a, Float32, /foo/i}
                partial = Spectator::Expectations::ValueExpectationPartial.new(array)
                matcher = Spectator::Matchers::HaveMatcher.new(search)
                matcher.match?(partial).should be_false
              end
            end

            context "non-matching regex" do
              it "is false" do
                array = [:a, 42, "FOO"]
                search = {:a, Float32, /bar/i}
                partial = Spectator::Expectations::ValueExpectationPartial.new(array)
                matcher = Spectator::Matchers::HaveMatcher.new(search)
                matcher.match?(partial).should be_false
              end
            end
          end
        end

        context "against one equal value" do
          it "is false" do
            array = %i[a b c]
            search = {:a, :d}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no equal values" do
          it "is false" do
            array = %i[a b c]
            search = {:d, :e}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against matching types" do
          it "is true" do
            array = [:a, 42, "FOO"]
            search = {Symbol, String}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one matching type" do
          it "is false" do
            array = [:a, 42, "FOO"]
            search = {Symbol, Float32}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no matching types" do
          it "is false" do
            array = [:a, 42, "FOO"]
            search = {Float32, Bytes}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against matching regexes" do
          it "is true" do
            array = %w[FOO BAR BAZ]
            search = {/foo/i, /bar/i}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one matching regex" do
          it "is false" do
            array = %w[FOO BAR BAZ]
            search = {/foo/i, /qux/i}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no matching regexes" do
          it "is false" do
            array = %w[FOO BAR]
            search = {/baz/i, /qux/i}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against equal and matching type and regex" do
          it "is true" do
            array = [:a, 42, "FOO"]
            search = {Symbol, Int32, String}
            partial = Spectator::Expectations::ValueExpectationPartial.new(array)
            matcher = Spectator::Matchers::HaveMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end
      end
    end
  end

  describe "#message" do
    it "contains the actual label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::HaveMatcher.new({search})
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::HaveMatcher.new(label, {search})
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        search = "baz"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::HaveMatcher.new({search})
        matcher.message(partial).should contain(search)
      end
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(label, value)
      matcher = Spectator::Matchers::HaveMatcher.new({search})
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = Spectator::Expectations::ValueExpectationPartial.new(value)
      matcher = Spectator::Matchers::HaveMatcher.new(label, {search})
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        search = "baz"
        partial = Spectator::Expectations::ValueExpectationPartial.new(value)
        matcher = Spectator::Matchers::HaveMatcher.new({search})
        matcher.negated_message(partial).should contain(search)
      end
    end
  end
end
