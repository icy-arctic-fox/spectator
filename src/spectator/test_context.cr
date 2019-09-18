module Spectator
  struct TestContext
    def initialize(@hooks : ExampleHooks)
      @before_all_hooks_run = false
      @after_all_hooks_run = false
    end

    def run_before_hooks(wrapper : TestWrapper)
      @hooks.run_before_all
      @hooks.run_before_each(wrapper)
    ensure
      @before_all_hooks_run = true
    end

    def run_after_hooks(wrapper : TestWrapper)
      @hooks.run_after_each(wrapper)
      @hooks.run_after_all
    ensure
      @after_all_hooks_run = true
    end
  end
end
