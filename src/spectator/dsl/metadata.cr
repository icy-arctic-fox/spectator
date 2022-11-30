module Spectator::DSL
  module Metadata
    # Defines a class method named *name* that combines metadata
    # returned by *source* with *tags* and *metadata*.
    # Any falsey items from *metadata* are removed.
    private macro _spectator_metadata(name, source, *tags, **metadata)
      private def self.{{name.id}}
        %metadata = {{source.id}}.dup
        {% unless tags.empty? && metadata.empty? %}
          %metadata ||= ::Spectator::Metadata.new
        {% end %}
        {% for k in tags %}
          %metadata[{{k.id.symbolize}}] = nil
        {% end %}
        {% for k, v in metadata %}
          %cond = begin
            {{v}}
          end
          if %cond
            %metadata[{{k.id.symbolize}}] = %cond.to_s
          else
            %metadata.delete({{k.id.symbolize}})
          end
        {% end %}
        %metadata
      end
    end
  end
end
