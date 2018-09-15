require "../example_group"

module Spectator
  module DSL
    module StructureDSL

      macro describe(what, type = "Describe", &block)
        context({{what}}, {{type}}) {{block}}
      end

      macro context(what, type = "Context", &block)
        {%
          parent_module = @type
          safe_name = what.id.stringify.chars.map { |c| ::Spectator::Definitions::SPECIAL_CHARS[c] || c }.join("").gsub(/\W+/, "_")
          module_name = (type.id + safe_name.camelcase).id
          absolute_module_name = [parent_module, module_name].join("::").id
          what_arg = what.is_a?(StringLiteral) ? what : what.stringify
          parent_given = ::Spectator::Definitions::ALL[parent_module.id][:given]

          ::Spectator::Definitions::ALL[absolute_module_name] = {
            name: module_name,
            parent: parent_module,
            given: parent_given.map { |e| e } # Duplicate elements without dup method.
          }
        %}

        ::Spectator::Definitions::MAPPING[{{absolute_module_name.stringify}}] =
          ExampleGroup.new({{what_arg}}, ::Spectator::Definitions::MAPPING[{{parent_module.stringify}}])

        module {{module_name.id}}
          include {{parent_module}}

          {% if what.is_a?(Path) || what.is_a?(Generic) %}
            def described_class
              {{what}}.tap do |thing|
                raise "#{thing} must be a type name to use #described_class or #subject,\
                 but it is a #{typeof(thing)}" unless thing.is_a?(Class)
              end
            end

            def subject
              described_class.new
            end
          {% end %}

          {{block.body}}
        end
      end

      macro given(collection, &block)
        {% parent_module = @type %}
        context({{collection}}, "Given") do
          {%
            var_name = block.args.empty? ? "value".id : block.args.first
            given_vars = ::Spectator::Definitions::ALL[parent_module.id][:given]
            if given_vars.find { |v| v[:name] == var_name.id }
              raise "Duplicate given variable name \"#{var_name.id}\""
            end
          %}

          def self.%collection
            {{collection}}
          end

          def self.{{var_name}}
            %collection.first
          end

          \{% ::Spectator::Definitions::ALL[@type.id][:given] << {name: "{{var_name}}".id, collection: "{{collection}}".id, type_def: (@type.id + ".{{var_name}}").id} %}

          {{block.body}}
        end
      end

      macro subject(&block)
        let(:subject) {{block}}
      end

      macro let(name, &block)
        let!(%value) {{block}}

        @%wrapper : ValueWrapper?

        def {{name.id}}
          if (wrapper = @%wrapper)
            wrapper.unsafe_as(TypedValueWrapper(typeof(%value))).value
          else
            %value.tap do |value|
              @%wrapper = TypedValueWrapper(typeof(%value)).new(value)
            end
          end
        end
      end

      macro let!(name, &block)
        def {{name.id}}
          {{block.body}}
        end
      end

      macro before_all(&block)
        ::Spectator::Definitions::MAPPING[{{@type.stringify}}].before_all_hooks << -> {{block}}
      end

      macro before_each(&block)
        ::Spectator::Definitions::MAPPING[{{@type.stringify}}].before_each_hooks << -> {{block}}
      end

      macro after_all(&block)
        ::Spectator::Definitions::MAPPING[{{@type.stringify}}].after_all_hooks << -> {{block}}
      end

      macro after_each(&block)
        ::Spectator::Definitions::MAPPING[{{@type.stringify}}].after_each_hooks << -> {{block}}
      end

      macro around_each(&block)
        ::Spectator::Definitions::MAPPING[{{@type.stringify}}].around_each_hooks << Proc(Proc(Nil), Nil).new {{block}}
      end

      def include_examples
        raise NotImplementedError.new("Spectator::DSL#include_examples")
      end

      macro it(description, &block)
        {%
          parent_module = @type
          safe_name = description.id.stringify.chars.map { |c| ::Spectator::Definitions::SPECIAL_CHARS[c] || c }.join("").gsub(/\W+/, "_")
          class_name = (safe_name.camelcase + "Example").id
          given_vars = ::Spectator::Definitions::ALL[parent_module.id][:given]
          var_names = given_vars.map { |v| v[:name] }
        %}

        class Example%example
          include ::Spectator::DSL::ExampleDSL
          include {{parent_module}}

          def %run({{ var_names.join(", ").id }})
            {{block.body}}
          end
        end

        class {{class_name.id}} < ::Spectator::RunnableExample
          {% for given_var, i in given_vars %}
            @%var{i} : ValueWrapper

            private def %var{i}
              @%var{i}.unsafe_as(TypedValueWrapper(typeof({{given_var[:type_def]}}))).value
            end
          {% end %}

          def initialize(group{% for v, i in var_names %}, %var{i}{% end %})
            super(group)
            {% for given_var, i in given_vars %}
              @%var{i} = TypedValueWrapper(typeof({{given_var[:type_def]}})).new(%var{i})
            {% end %}
          end

          protected def run_instance
            Example%example.new.%run({% for v, i in var_names %}%var{i}{% if i < var_names.size - 1 %}, {% end %}{% end %})
          end

          def description
            {% if description.is_a?(StringLiteral) %}
              {{description}}
            {% else %}
              {{description.stringify}}
            {% end %}
          end
        end

        %current_group = ::Spectator::Definitions::MAPPING[{{parent_module.stringify}}]
        {% for given_var, i in given_vars %}
          {%
            var_name = given_var[:name]
            collection = given_var[:collection]
          %}
          {{collection}}.each do |%var{i}|
        {% end %}
        %current_group.examples << {{class_name.id}}.new(%current_group {% for v, i in var_names %}, %var{i}{% end %})
        {% for given_var in given_vars %}
          end
        {% end %}
      end

      macro pending(description, &block)
        {%
          parent_module = @type
          safe_name = description.id.stringify.chars.map { |c| ::Spectator::Definitions::SPECIAL_CHARS[c] || c }.join("").gsub(/\W+/, "_")
          class_name = (safe_name.camelcase + "Example").id
          given_vars = ::Spectator::Definitions::ALL[parent_module.id][:given]
          var_names = given_vars.map { |v| v[:name] }
        %}

        class Example%example
          include ::Spectator::DSL::ExampleDSL
          include {{parent_module}}

          def %run({{ var_names.join(", ").id }})
            {{block.body}}
          end
        end

        class {{class_name.id}} < ::Spectator::PendingExample
          {% for given_var, i in given_vars %}
            @%var{i} : ValueWrapper

            private def %var{i}
              @%var{i}.unsafe_as(TypedValueWrapper(typeof({{given_var[:type_def]}}))).value
            end
          {% end %}

          def initialize(group{% for v, i in var_names %}, %var{i}{% end %})
            super(group)
            {% for given_var, i in given_vars %}
              @%var{i} = TypedValueWrapper(typeof({{given_var[:type_def]}})).new(%var{i})
            {% end %}
          end

          def description
            {% if description.is_a?(StringLiteral) %}
              {{description}}
            {% else %}
              {{description.stringify}}
            {% end %}
          end
        end

        %current_group = ::Spectator::Definitions::MAPPING[{{parent_module.stringify}}]
        {% for given_var, i in given_vars %}
          {%
            var_name = given_var[:name]
            collection = given_var[:collection]
          %}
          {{collection}}.each do |%var{i}|
        {% end %}
        %current_group.examples << {{class_name.id}}.new(%current_group {% for v, i in var_names %}, %var{i}{% end %})
        {% for given_var in given_vars %}
          end
        {% end %}
      end

      def it_behaves_like
        raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
      end
    end
  end
end
