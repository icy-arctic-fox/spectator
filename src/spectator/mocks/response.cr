require "./abstract_arguments"
require "./abstract_response"

module Spectator
  class Response(T) < AbstractResponse
    # Return value.
    getter value : T

    # Arguments the method must have been called with to provide this response.
    # Is nil when there's no constraint - only the method name must match.
    getter constraint : AbstractArguments?

    # Creates the response.
    def initialize(@method : Symbol, @value : T, @constraint : Arguments? = nil)
    end

    def ===(call : MethodCall)
      return false if method != call.method
      return true unless constraint = @constraint

      constraint === call.arguments
    end
  end
end
