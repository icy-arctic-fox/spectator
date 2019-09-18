module Spectator
  class TestContext
    def initialize(@parent : TestContext?, @hooks : ExampleHooks)
      @before_all_hooks_run = false
      @after_all_hooks_run = false
    end

    def run_before_hooks(wrapper : TestWrapper)
      run_before_all_hooks
      run_before_each_hooks(wrapper)
    end

    protected def run_before_all_hooks
      return if @before_all_hooks_run

      @parent.try &.run_before_all_hooks
      @hooks.run_before_all
    ensure
      @before_all_hooks_run = true
    end

    protected def run_before_each_hooks(wrapper : TestWrapper)
      @parent.try &.run_before_each_hooks(wrapper)
      @hooks.run_before_each(wrapper)
    end

    def run_after_hooks(wrapper : TestWrapper)
      run_after_each_hooks(wrapper)
      run_after_all_hooks
    end

    protected def run_after_all_hooks
      return if @after_all_hooks_run

      @hooks.run_after_all
      @parent.try &.run_after_all_hooks
    ensure
      @after_all_hooks_run = true
    end

    protected def run_after_each_hooks(wrapper : TestWrapper)
      @hooks.run_after_each(wrapper)
      @parent.try &.run_after_each_hooks(wrapper)
    end
  end
end
