require "./spec_helper"

describe Spectator::ExampleConditions do
  {% for condition in %i[pre_condition post_condition] %}
    describe "#run_{{condition.id}}s" do
      it "calls a proc" do
        called = false
        conditions = new_conditions({{condition.id}}: ->{ called = true; nil })
        conditions.run_{{condition.id}}s
        called.should be_true
      end

      it "calls multiple procs" do
        call_count = 0
        conditions = new_conditions({{condition.id}}s: [
          ->{ call_count += 1; nil },
          ->{ call_count += 2; nil },
          ->{ call_count += 3; nil },
        ])
        conditions.run_{{condition.id}}s
        call_count.should eq(6)
      end

      it "calls procs in the correct order" do
        calls = [] of Symbol
        conditions = new_conditions({{condition.id}}s: [
          ->{ calls << :a; nil },
          ->{ calls << :b; nil },
          ->{ calls << :c; nil },
        ])
        conditions.run_{{condition.id}}s
        calls.should eq(\%i[a b c])
      end
    end
  {% end %}
end
