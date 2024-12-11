require "../formatting"

module Spectator::Matchers::BuiltIn
  struct HaveAttributesMatcher(Attributes)
    include Formatting

    private struct Attribute(E, A)
      getter expected : Formatting::DescriptionOf(E)
      getter actual : Formatting::DescriptionOf(A)?
      getter? matched : Bool

      def initialize(@matched : Bool, expected : E, actual : A?)
        @expected = Formatting::DescriptionOf.new(expected)
        @actual = Formatting::DescriptionOf.new(actual) if actual
      end

      def self.missing(expected_value) : self
        new(false, expected_value, nil)
      end
    end

    def initialize(@attributes : Attributes)
    end

    def match(actual_value) : MatchFailure?
      attributes = capture_attributes(actual_value)
      return if attributes_match?(attributes)
      MatchFailure.new do |printer|
        {% for key in Attributes %}
          attribute = attributes[{{key.stringify}}]
          unless attribute.matched?
            printer << "Expected " << method_name({{key.symbolize}}) << ": " << attribute.expected << EOL
            printer << "     got " << method_name({{key.symbolize}}) << ": " << attribute.actual << EOL
          end
        {% end %}
      end
    end

    def match_negated(actual_value) : MatchFailure?
      attributes = capture_attributes(actual_value)
      return unless attributes_match?(attributes)
      MatchFailure.new do |printer|
        {% for key in Attributes %}
          attribute = attributes[{{key.stringify}}]
          if attribute.matched?
            printer << "Expected " << method_name({{key.symbolize}}) << ": not " << attribute.expected << EOL
            printer << "     got " << method_name({{key.symbolize}}) << ": " << attribute.actual << EOL
          end
        {% end %}
      end
    end

    private def attributes_match?(attributes)
      attributes.each_value do |attribute|
        return false unless attribute.matched?
      end
      true
    end

    private def capture_attributes(actual_value)
      {% begin %}
        NamedTuple.new({% for key in Attributes %}
          {{key.stringify}}: capture_attribute(actual_value, {{key}}),
        {% end %})
      {% end %}
    end

    private macro capture_attribute(actual_value, key)
      expected = @attributes[{{key.symbolize}}]
      attribute = if {{actual_value}}.responds_to?({{key.symbolize}})
        value = {{actual_value}}.{{key}}
        matched = value == expected
        Attribute.new(matched, expected, value)
      else
        Attribute.missing(expected)
      end
    end
  end
end
