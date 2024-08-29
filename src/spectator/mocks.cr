require "mocks"
require "./core"

Spectator.configure do |config|
  config.before_suite { Mocks.enable }
  config.after_suite { Mocks.disable }
  config.around_each do |example|
    Mocks::Scope.push do
      example.run
    end
  end
end

include Mocks::DSL::AllowSyntax
