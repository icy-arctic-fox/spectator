require "./matchers/should_methods"

class Object
  include Spectator::Matchers::ShouldMethods
end
