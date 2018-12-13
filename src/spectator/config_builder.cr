module Spectator
  class ConfigBuilder
    property formatter : Formatters::Formatter = Formatters::DefaultFormatter.new

    def build
      Config.new
    end
  end
end
