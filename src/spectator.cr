require "./spectator/*"

# TODO: Write documentation for `Spectator`
module Spectator
  VERSION = "0.1.0"

  macro describe(what, &block)
    DSL.root({{what}}) {{block}}
  end

  at_exit do
    begin
      Runner.new(ExampleGroup::ROOT).run
    rescue ex
      puts
      puts "Encountered an unexpected error in framework"
      puts ex.message
      puts ex.backtrace.join("\n")
      exit(1)
    end
  end
end
