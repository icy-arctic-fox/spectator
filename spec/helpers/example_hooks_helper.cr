# Creates a new `Spectator::ExampleHooks` instance.
# All arguments are optional,
# only specify the sets of hooks that are needed.
# The hooks that aren't specified will be left empty.
def new_hooks(
  before_all = [] of ->,
  before_each = [] of ->,
  after_all = [] of ->,
  after_each = [] of ->,
  around_each = [] of Proc(Nil) ->
)
  Spectator::ExampleHooks.new(before_all, before_each,
    after_all, after_each, around_each)
end

# Creates a new `Spectator::ExampleHooks` instance.
# All arguments are optional,
# only specify a hook for the types that are needed.
# The hooks that aren't specified will be left empty.
def new_hooks(
  before_all : Proc(Nil)? = nil,
  before_each : Proc(Nil)? = nil,
  after_all : Proc(Nil)? = nil,
  after_each : Proc(Nil)? = nil,
  around_each : Proc(Proc(Nil), Nil)? = nil
)
  new_hooks(
    before_all ? [before_all] : [] of ->,
    before_each ? [before_each] : [] of ->,
    after_all ? [after_all] : [] of ->,
    after_each ? [after_each] : [] of ->,
    around_each ? [around_each] : [] of Proc(Nil) ->
  )
end

# Creates a new `Spectator::ExampleConditions` instance.
# All arguments are optional,
# only specify the sets of conditions that are needed.
# The conditions that aren't specified will be left empty.
def new_conditions(
  pre = [] of ->,
  post = [] of ->
)
  Spectator::ExampleConditions.new(pre, post)
end

# Creates a new `Spectator::ExampleConditions` instance.
# All arguments are optional,
# only specify a condition for the types that are needed.
# The conditions that aren't specified will be left empty.
def new_conditions(
  pre : Proc(Nil)? = nil,
  post : Proc(Nil)? = nil
)
  new_conditions(
    pre ? [pre] : [] of ->,
    post ? [post] : [] of ->
  )
end
