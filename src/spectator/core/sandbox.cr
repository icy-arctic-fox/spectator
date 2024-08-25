module Spectator
  module Core
    class Sandbox
    end
  end

  protected class_property sandbox = Core::Sandbox.new

  def self.with_sandbox(& : Core::Sandbox ->)
    previous_sandbox = self.sandbox
    sandbox = Core::Sandbox.new
    begin
      self.sandbox = sandbox
      yield sandbox
    ensure
      self.sandbox = previous_sandbox
    end
  end

  macro sandbox_getter(prop)
    module ::Spectator
      {% if prop.is_a?(TypeDeclaration)
           name = prop.var
         elsif prop.is_a?(Assign)
           name = prop.target
         else
           name = prop
         end %}
      def self.{{name.id}}
        sandbox.{{name.id}}
      end

      class Core::Sandbox
        getter {{prop}}
      end
    end
  end

  macro sandbox_property(prop)
    module ::Spectator
      {% if prop.is_a?(TypeDeclaration)
           name = prop.var
         elsif prop.is_a?(Assign)
           name = prop.target
         else
           name = prop
         end %}
      def self.{{name.id}}
        sandbox.{{name.id}}
      end

      def self.{{name.id}}=(value)
        sandbox.{{name.id}} = value
      end

      class Core::Sandbox
        property {{prop}}
      end
    end
  end
end
