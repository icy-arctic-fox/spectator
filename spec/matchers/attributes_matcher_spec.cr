require "../spec_helper"

describe Spectator::Matchers::AttributesMatcher do
  describe "#match" do
    it "uses ===" do
      array = %i[a b c]
      spy = SpySUT.new
      partial = new_partial(array)
      matcher = Spectator::Matchers::AttributesMatcher.new({first: spy})
      matcher.match(partial)
      spy.case_eq_call_count.should be > 0
    end

    context "returned MatchData" do
      describe "#matched?" do
        context "one argument" do
          context "against an equal value" do
            it "is true" do
              array = %i[a b c]
              attributes = {first: :a}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "against a different value" do
            it "is false" do
              array = %i[a b c]
              attributes = {first: :z}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against a matching type" do
            it "is true" do
              array = %i[a b c]
              attributes = {first: Symbol}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "against a non-matching type" do
            it "is false" do
              array = %i[a b c]
              attributes = {first: Int32}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against a matching regex" do
            it "is true" do
              array = %w[FOO BAR BAZ]
              attributes = {first: /foo/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "against a non-matching regex" do
            it "is false" do
              array = %w[FOO BAR BAZ]
              attributes = {first: /qux/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end
        end

        context "multiple attributes" do
          context "against equal values" do
            it "is true" do
              array = %i[a b c]
              attributes = {first: :a, last: :c}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end

            context "matching type" do
              context "matching regex" do
                it "is true" do
                  array = [:a, 42, "FOO"]
                  attributes = {first: Symbol, last: /foo/i}
                  partial = new_partial(array)
                  matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
                  match_data = matcher.match(partial)
                  match_data.matched?.should be_true
                end
              end

              context "non-matching regex" do
                it "is false" do
                  array = [:a, 42, "FOO"]
                  attributes = {first: Symbol, last: /bar/i}
                  partial = new_partial(array)
                  matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
                  match_data = matcher.match(partial)
                  match_data.matched?.should be_false
                end
              end
            end

            context "non-matching type" do
              context "matching regex" do
                it "is false" do
                  array = [:a, 42, "FOO"]
                  attributes = {first: Float32, last: /foo/i}
                  partial = new_partial(array)
                  matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
                  match_data = matcher.match(partial)
                  match_data.matched?.should be_false
                end
              end

              context "non-matching regex" do
                it "is false" do
                  array = [:a, 42, "FOO"]
                  attributes = {first: Float32, last: /bar/i}
                  partial = new_partial(array)
                  matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
                  match_data = matcher.match(partial)
                  match_data.matched?.should be_false
                end
              end
            end
          end

          context "against one equal value" do
            it "is false" do
              array = %i[a b c]
              attributes = {first: :a, last: :d}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against no equal values" do
            it "is false" do
              array = %i[a b c]
              attributes = {first: :d, last: :e}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against matching types" do
            it "is true" do
              array = [:a, 42, "FOO"]
              attributes = {first: Symbol, last: String}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "against one matching type" do
            it "is false" do
              array = [:a, 42, "FOO"]
              attributes = {first: Symbol, last: Float32}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against no matching types" do
            it "is false" do
              array = [:a, 42, "FOO"]
              attributes = {first: Float32, last: Bytes}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against matching regexes" do
            it "is true" do
              array = %w[FOO BAR BAZ]
              attributes = {first: /foo/i, last: /baz/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end

          context "against one matching regex" do
            it "is false" do
              array = %w[FOO BAR BAZ]
              attributes = {first: /foo/i, last: /qux/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against no matching regexes" do
            it "is false" do
              array = %w[FOO BAR]
              attributes = {first: /baz/i, last: /qux/i}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_false
            end
          end

          context "against equal and matching type and regex" do
            it "is true" do
              array = [:a, 42, "FOO"]
              attributes = {first: Symbol, last: /foo/i, size: 3}
              partial = new_partial(array)
              matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
              match_data = matcher.match(partial)
              match_data.matched?.should be_true
            end
          end
        end
      end

      describe "#values" do
        it "contains a key for each expected attribute" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: /foo/i, size: 3}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          match_data = matcher.match(partial)
          match_data_has_key?(match_data, :"expected first").should be_true
          match_data_has_key?(match_data, :"expected last").should be_true
          match_data_has_key?(match_data, :"expected size").should be_true
        end

        it "contains a key for each actual value" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: /foo/i, size: 3}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          match_data = matcher.match(partial)
          match_data_has_key?(match_data, :"actual first").should be_true
          match_data_has_key?(match_data, :"actual last").should be_true
          match_data_has_key?(match_data, :"actual size").should be_true
        end

        it "has the expected values" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: /foo/i, size: 3}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          match_data = matcher.match(partial)
          match_data_value_sans_prefix(match_data, :"expected first")[:value].should eq(attributes[:first])
          match_data_value_sans_prefix(match_data, :"expected last")[:value].should eq(attributes[:last])
          match_data_value_sans_prefix(match_data, :"expected size")[:value].should eq(attributes[:size])
        end

        it "has the actual values" do
          array = [:a, 42, "FOO"]
          attributes = {first: Symbol, last: /foo/i, size: 3}
          partial = new_partial(array)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          match_data = matcher.match(partial)
          match_data_value_sans_prefix(match_data, :"actual first")[:value].should eq(array.first)
          match_data_value_sans_prefix(match_data, :"actual last")[:value].should eq(array.last)
          match_data_value_sans_prefix(match_data, :"actual size")[:value].should eq(array.size)
        end
      end

      describe "#message" do
        it "contains the actual label" do
          value = "foobar"
          attributes = {size: 6}
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          attributes = {size: 6}
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes, label)
          match_data = matcher.match(partial)
          match_data.message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value = "foobar"
            attributes = {size: 6}
            partial = new_partial(value)
            matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
            match_data = matcher.match(partial)
            match_data.message.should contain(attributes.to_s)
          end
        end
      end

      describe "#negated_message" do
        it "contains the actual label" do
          value = "foobar"
          attributes = {size: 6}
          label = "everything"
          partial = new_partial(value, label)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        it "contains the expected label" do
          value = "foobar"
          attributes = {size: 6}
          label = "everything"
          partial = new_partial(value)
          matcher = Spectator::Matchers::AttributesMatcher.new(attributes, label)
          match_data = matcher.match(partial)
          match_data.negated_message.should contain(label)
        end

        context "when expected label is omitted" do
          it "contains stringified form of expected value" do
            value = "foobar"
            attributes = {size: 6}
            partial = new_partial(value)
            matcher = Spectator::Matchers::AttributesMatcher.new(attributes)
            match_data = matcher.match(partial)
            match_data.negated_message.should contain(attributes.to_s)
          end
        end
      end
    end
  end
end
