module Spectator
  module Core
    class Sandbox
    end
  end

  protected class_property sandbox = Core::Sandbox.new

  def self.with_sandbox(& : Sandbox ->)
    previous_sandbox = self.sandbox
    sandbox = Sandbox.new
    begin
      self.sandbox = sandbox
      yield sandbox
    ensure
      self.sandbox = previous_sandbox
    end
  end
end
