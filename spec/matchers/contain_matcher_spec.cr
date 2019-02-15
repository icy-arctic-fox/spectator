require "../spec_helper"

describe Spectator::Matchers::ContainMatcher do
  describe "#match?" do
    context "with a String" do
      context "one argument" do
        context "against a matching string" do
          it "is true" do
            value = "foobarbaz"
            search = "bar"
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              value = "foobar"
              search = "foo"
              partial = new_partial(value)
              matcher = Spectator::Matchers::ContainMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              value = "foobar"
              search = "bar"
              partial = new_partial(value)
              matcher = Spectator::Matchers::ContainMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a different string" do
          it "is false" do
            value = "foobar"
            search = "baz"
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end

        context "against a matching character" do
          it "is true" do
            value = "foobar"
            search = 'o'
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              value = "foobar"
              search = 'f'
              partial = new_partial(value)
              matcher = Spectator::Matchers::ContainMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              value = "foobar"
              search = 'r'
              partial = new_partial(value)
              matcher = Spectator::Matchers::ContainMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a different character" do
          it "is false" do
            value = "foobar"
            search = 'z'
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end
      end

      context "multiple arguments" do
        context "against matching strings" do
          it "is true" do
            value = "foobarbaz"
            search = {"foo", "bar", "baz"}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one matching string" do
          it "is false" do
            value = "foobarbaz"
            search = {"foo", "qux"}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no matching strings" do
          it "is false" do
            value = "foobar"
            search = {"baz", "qux"}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against matching characters" do
          it "is true" do
            value = "foobarbaz"
            search = {'f', 'b', 'z'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one matching character" do
          it "is false" do
            value = "foobarbaz"
            search = {'f', 'c', 'd'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no matching characters" do
          it "is false" do
            value = "foobarbaz"
            search = {'c', 'd', 'e'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against a matching string and character" do
          it "is true" do
            value = "foobarbaz"
            search = {"foo", 'z'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against a matching string and non-matching character" do
          it "is false" do
            value = "foobarbaz"
            search = {"foo", 'c'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against a non-matching string and matching character" do
          it "is false" do
            value = "foobarbaz"
            search = {"qux", 'f'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against a non-matching string and character" do
          it "is false" do
            value = "foobarbaz"
            search = {"qux", 'c'}
            partial = new_partial(value)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
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
            partial = new_partial(array)
            matcher = Spectator::Matchers::ContainMatcher.new({search})
            matcher.match?(partial).should be_true
          end

          context "at the beginning" do
            it "is true" do
              array = %i[a b c]
              search = :a
              partial = new_partial(array)
              matcher = Spectator::Matchers::ContainMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end

          context "at the end" do
            it "is true" do
              array = %i[a b c]
              search = :c
              partial = new_partial(array)
              matcher = Spectator::Matchers::ContainMatcher.new({search})
              matcher.match?(partial).should be_true
            end
          end
        end

        context "against a different value" do
          it "is false" do
            array = %i[a b c]
            search = :z
            partial = new_partial(array)
            matcher = Spectator::Matchers::ContainMatcher.new({search})
            matcher.match?(partial).should be_false
          end
        end
      end

      context "multiple arguments" do
        context "against equal values" do
          it "is true" do
            array = %i[a b c]
            search = {:a, :b}
            partial = new_partial(array)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_true
          end
        end

        context "against one equal value" do
          it "is false" do
            array = %i[a b c]
            search = {:a, :d}
            partial = new_partial(array)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
          end
        end

        context "against no equal values" do
          it "is false" do
            array = %i[a b c]
            search = {:d, :e}
            partial = new_partial(array)
            matcher = Spectator::Matchers::ContainMatcher.new(search)
            matcher.match?(partial).should be_false
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
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::ContainMatcher.new({search})
      matcher.message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::ContainMatcher.new(label, {search})
      matcher.message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        search = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::ContainMatcher.new({search})
        matcher.message(partial).should contain(search)
      end
    end
  end

  describe "#negated_message" do
    it "contains the actual label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = new_partial(value, label)
      matcher = Spectator::Matchers::ContainMatcher.new({search})
      matcher.negated_message(partial).should contain(label)
    end

    it "contains the expected label" do
      value = "foobar"
      search = "baz"
      label = "everything"
      partial = new_partial(value)
      matcher = Spectator::Matchers::ContainMatcher.new(label, {search})
      matcher.negated_message(partial).should contain(label)
    end

    context "when expected label is omitted" do
      it "contains stringified form of expected value" do
        value = "foobar"
        search = "baz"
        partial = new_partial(value)
        matcher = Spectator::Matchers::ContainMatcher.new({search})
        matcher.negated_message(partial).should contain(search)
      end
    end
  end
end
