require "./example_group"

module Spectator
  module DSL

    SPECIAL_CHAR_MAPPING = {
      '~' => "Tilde",
      '`' => "Tick",
      '!' => "Bang",
      '@' => "At",
      '#' => "Hash",
      '$' => "Dollar",
      '%' => "Percent",
      '^' => "Carret",
      '&' => "And",
      '*' => "Star",
      '(' => "LParen",
      ')' => "RParen",
      '+' => "Plus",
      '=' => "Eq",
      '{' => "LBrace",
      '}' => "RBrace",
      '[' => "LBracket",
      ']' => "RBracket",
      ':' => "Colon",
      ';' => "SColon",
      '<' => "Lt",
      '>' => "Gt",
      ',' => "Comma",
      '.' => "Dot",
      '?' => "Question",
      '/' => "Slash",
      '"' => "DQuote",
      '|' => "Or",
      '\\' => "BSlash",
      '\'' => "SQuote"
    }

    macro describe(what, type = "Describe", &block)
      context({{what}}, {{type}}) {{block}}
    end

    macro context(what, type = "Context", &block)
      {% parent_module = @type %}
      {% safe_name = what.id.stringify.chars.map { |c| SPECIAL_CHAR_MAPPING[c] || c }.join("").gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      {% absolute_module_name = [parent_module, module_name].join("::").id %}
      {% what_arg = what.is_a?(StringLiteral) ? what : what.stringify %}
      {% parent_given = ::Spectator::ContextDefinitions::ALL[parent_module.id][:given] %}
      module {{module_name.id}}
        include ::Spectator::DSL

        {% ::Spectator::ContextDefinitions::ALL[absolute_module_name] = {
          name: module_name,
          parent: parent_module,
          given: parent_given.map { |e| e } # Duplicate elements without dup method.
        } %}
        ::Spectator::ContextDefinitions::MAPPING[{{absolute_module_name.stringify}}] = Context.new({{what_arg}}, ::Spectator::ContextDefinitions::MAPPING[{{parent_module.stringify}}])

        module Locals
          include {{parent_module}}::Locals

          {% if what.is_a?(Path) %}
            def described_class
              {{what}}
            end
          {% end %}
        end

        {{block.body}}
      end
    end

    macro it(description, &block)
      {% parent_module = @type %}
      {% safe_name = description.id.stringify.chars.map { |c| SPECIAL_CHAR_MAPPING[c] || c }.join("").gsub(/\W+/, "_") %}
      {% class_name = (safe_name.camelcase + "Example").id %}
      {% given_vars = ::Spectator::ContextDefinitions::ALL[parent_module.id][:given] %}
      {% var_names = given_vars.map { |v| v[:name] } %}
      class {{class_name.id}} < ::Spectator::Example
        include Locals

        {% if given_vars.empty? %}
          def initialize(context)
            super(context)
          end
        {% else %}
          def initialize(context, {{ var_names.join(", ").id }})
            super(context)
            {% for given_var in given_vars %}
              {{given_var[:setter]}}({{given_var[:name]}})
            {% end %}
          end
        {% end %}

        def run
          {{block.body}}
        end

        def description
          {% if description.is_a?(StringLiteral) %}
            {{description}}
          {% else %}
            {{description.stringify}}
          {% end %}
        end
      end

      %current_context = ::Spectator::ContextDefinitions::MAPPING[{{parent_module.stringify}}]
      {% if given_vars.empty? %}
        %current_context.examples << {{class_name.id}}.new(%current_context)
      {% else %}
        {% for given_var in given_vars %}
          {% var_name = given_var[:name] %}
          {% collection = given_var[:collection] %}
          {{collection}}.each do |{{var_name}}|
        {% end %}
        %current_context.examples << {{class_name.id}}.new(%current_context, {{var_names.join(", ").id}})
        {% for given_var in given_vars %}
          end
        {% end %}
      {% end %}
    end

    def it_behaves_like
      raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
    end

    macro subject(&block)
      let(:subject) {{block}}
    end

    macro let(name, &block)
      let!(%value) {{block}}

      module Locals
        @%wrapper : ValueWrapper?

        def {{name.id}}
          if (wrapper = @%wrapper)
            wrapper.as(TypedValueWrapper(typeof(%value))).value
          else
            %value.tap do |value|
              @%wrapper = TypedValueWrapper(typeof(%value)).new(value)
            end
          end
        end
      end
    end

    macro let!(name, &block)
      module Locals
        def {{name.id}}
          {{block.body}}
        end
      end
    end

    macro given(collection, &block)
      {% parent_module = @type %}
      context({{collection}}, "Given") do
        {% var_name = block.args.empty? ? "value".id : block.args.first %}
        {% given_vars = ::Spectator::ContextDefinitions::ALL[parent_module.id][:given] %}
        {% if given_vars.find { |v| v[:name] == var_name.id } %}
          {% raise "Duplicate given variable name \"#{var_name.id}\"" %}
        {% end %}

        module Locals
          @%wrapper : ValueWrapper?

          private def %collection
            {{collection}}
          end

          private def %collection_first
            %collection.first
          end

          def {{var_name.id}}
            @%wrapper.as(TypedValueWrapper(typeof(%collection_first))).value
          end

          {% setter = "_set_#{var_name.id}".id %}
          private def {{setter}}(value)
            @%wrapper = TypedValueWrapper(typeof(%collection_first)).new(value)
          end
        end

        \{% ::Spectator::ContextDefinitions::ALL[@type.id][:given] << {name: "{{var_name}}".id, collection: "{{collection}}".id, setter: "{{setter}}".id} %}

        {{block.body}}
      end
    end

    macro before_all(&block)
      ::Spectator::ContextDefinitions::MAPPING[{{@type.stringify}}].before_all_hooks << -> {{block}}
    end

    macro before_each(&block)
      ::Spectator::ContextDefinitions::MAPPING[{{@type.stringify}}].before_each_hooks << -> {{block}}
    end

    macro after_all(&block)
      ::Spectator::ContextDefinitions::MAPPING[{{@type.stringify}}].after_all_hooks << -> {{block}}
    end

    macro after_each(&block)
      ::Spectator::ContextDefinitions::MAPPING[{{@type.stringify}}].after_each_hooks << -> {{block}}
    end

    macro around_each(&block)
      ::Spectator::ContextDefinitions::MAPPING[{{@type.stringify}}].around_each_hooks << -> {{block}}
    end

    def include_examples
      raise NotImplementedError.new("Spectator::DSL#include_examples")
    end
  end
end
