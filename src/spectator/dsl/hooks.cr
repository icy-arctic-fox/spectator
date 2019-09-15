module Spectator
  module DSL
    macro before_each(&block)
      def %hook : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_before_each_hook { |test| test.as({{@type.id}}).%hook }
    end

    macro after_each(&block)
      def %hook : Nil
        {{block.body}}
      end

      ::Spectator::SpecBuilder.add_after_each_hook { |test| test.as({{@type.id}}).%hook }
    end

    macro before_all(&block)
      ::Spectator::SpecBuilder.add_before_all_hook {{block}}
    end

    macro after_all(&block)
      ::Spectator::SpecBuilder.add_after_all_hook {{block}}
    end

    macro around_each(&block)
      def %hook({{block.args.splat}}) : Nil
        {{block.body}}
      end

      # TODO: Handle wrapping proc and test together.
    end
  end
end
