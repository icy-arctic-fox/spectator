module Spectator
  class ExampleHooks
    def self.empty
      new(
        [] of ->,
        [] of ->,
        [] of ->,
        [] of ->,
        [] of Proc(Nil) ->
      )
    end

    def initialize(
      @before_all : Array(->),
      @before_each : Array(->),
      @after_all : Array(->),
      @after_each : Array(->),
      @around_each : Array(Proc(Nil) ->)
    )
    end

    def run_before_all
      @before_all.each(&.call)
    end

    def run_before_each
      @before_each.each(&.call)
    end

    def run_after_all
      @after_all.each(&.call)
    end

    def run_after_each
      @after_each.each(&.call)
    end

    def wrap_around_each(&block : ->)
      wrapper = block
      @around_each.reverse_each do |hook|
        wrapper = wrap_proc(hook, wrapper)
      end
      wrapper
    end

    private def wrap_proc(inner : Proc(Nil) ->, wrapper : ->)
      ->{ inner.call(wrapper) }
    end
  end
end
