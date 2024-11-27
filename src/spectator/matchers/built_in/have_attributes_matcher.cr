module Spectator::Matchers::BuiltIn
  class HaveAttributesMatcher(Attributes)
    private struct Attribute(T)
      getter expected_value : T
      getter expected_string : String
      getter actual_string : String?
      getter? matched : Bool

      def initialize(@expected_value : T, @matched : Bool, @actual_string : String?)
        @expected_string = @expected_value.inspect
      end

      def self.missing(expected_value) : self
        new(expected_value, false, nil)
      end
    end

    def initialize(attributes : Attributes)
      {% begin %}
        # @attributes = NamedTuple.new({% for key in Attributes %}
        #   {{key.stringify}}: 42, # Attribute.missing(attributes[{{key.symbolize}}]),
        # {% end %})
        {% debug %}
      {% end %}
    end

    def matches?(actual_value)
      @attributes = capture_attributes(actual_value)
      @attributes.all? &.matched?
    end

    private def capture_attributes(actual_value)
      {% for key in Attributes %}
        %expected{key} = @attributes[{{key.stringify}}].expected_value
        %attribute{key} = if actual_value.responds_to?({{key.symbolize}})
          value = actual_value.{{key.symbolize}}
          Attribute.new(%expected{key}, value == %expected{key}, value.inspect)
        else
          Attribute.missing(%expected{key})
        end
      {% end %}

      NamedTuple.new({% for key in Attributes %}
        {{key.stringify}}: %attribute{key},
      {% end %})
    end

    def failure_message(actual_value)
    end
  end
end
