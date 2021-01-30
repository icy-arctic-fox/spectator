module Spectator::DSL
  module Tags
    # Defines a class method named *name* that combines tags
    # returned by *source* with *tags* and *metadata*.
    # Any falsey items from *metadata* are removed.
    private macro _spectator_tags(name, source, *tags, **metadata)
      def self.{{name.id}}
        %tags = {{source.id}}
        {% unless tags.empty? %}
          %tags.concat({ {{tags.map(&.id.symbolize).splat}} })
        {% end %}
        {% for k, v in metadata %}
          %cond = begin
            {{v}}
          end
          if %cond
            %tags.add({{k.id.symbolize}})
          else
            %tags.delete({{k.id.symbolize}})
          end
        {% end %}
        %tags
      end
    end
  end
end
