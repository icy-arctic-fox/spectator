module Spectator::DSL
  module Tags
    # Defines a class method named *name* that combines tags
    # returned by *source* with *tags* and *metadata*.
    # Any falsey items from *metadata* are removed.
    private macro _spectator_tags(name, source, *tags, **metadata)
      private def self.{{name.id}}
        %tags = {{source.id}}
        {% for k in tags %}
          %tags[{{k.id.symbolize}}] = nil
        {% end %}
        {% for k, v in metadata %}
          %cond = begin
            {{v}}
          end
          if %cond
            %tags[{{k.id.symbolize}}] = %cond
          else
            %tags.delete({{k.id.symbolize}})
          end
        {% end %}
        %tags
      end
    end
  end
end
