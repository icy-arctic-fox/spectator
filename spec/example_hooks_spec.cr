require "./spec_helper"

describe Spectator::ExampleHooks do
  {% for hook in %i[before_all before_each after_all after_each] %}
    describe "#run_{{hook.id}}" do
      it "calls a proc" do
        called = false
        hooks = new_hooks({{hook.id}}: ->{ called = true; nil })
        hooks.run_{{hook.id}}
        called.should be_true
      end

      it "calls multiple procs" do
        call_count = 0
        hooks = new_hooks({{hook.id}}: [
          ->{ call_count += 1; nil },
          ->{ call_count += 2; nil },
          ->{ call_count += 3; nil },
        ])
        hooks.run_{{hook.id}}
        call_count.should eq(6)
      end

      it "calls procs in the correct order" do
        calls = [] of Symbol
        hooks = new_hooks({{hook.id}}: [
          ->{ calls << :a; nil },
          ->{ calls << :b; nil },
          ->{ calls << :c; nil },
        ])
        hooks.run_{{hook.id}}
        calls.should eq(\%i[a b c])
      end
    end
  {% end %}

  describe "#wrap_around_each" do
    it "wraps the block" do
      called = false
      wrapper = new_hooks.wrap_around_each do
        called = true
      end
      wrapper.call
      called.should be_true
    end

    it "wraps a proc" do
      called = false
      hooks = new_hooks(around_each: ->(proc : ->) { called = true; proc.call })
      wrapper = hooks.wrap_around_each { }
      wrapper.call
      called.should be_true
    end

    it "wraps multiple procs" do
      call_count = 0
      hooks = new_hooks(around_each: [
        ->(proc : ->) { call_count += 1; proc.call },
        ->(proc : ->) { call_count += 2; proc.call },
        ->(proc : ->) { call_count += 3; proc.call },
      ])
      wrapper = hooks.wrap_around_each { }
      wrapper.call
      call_count.should eq(6)
    end

    it "wraps procs in the correct order" do
      calls = [] of Symbol
      hooks = new_hooks(around_each: [
        ->(proc : ->) { calls << :a; proc.call },
        ->(proc : ->) { calls << :b; proc.call },
        ->(proc : ->) { calls << :c; proc.call },
      ])
      wrapper = hooks.wrap_around_each { }
      wrapper.call
      calls.should eq(%i[a b c])
    end
  end
end
