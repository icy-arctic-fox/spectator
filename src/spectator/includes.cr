# This file includes all source files *except* `should.cr`.
# The `should.cr` file contains the optional feature for using should-syntax.
# Since this is disabled by default, we don't include all files.
# Including all files with a wildcard would accidentally enable should-syntax.
# Unfortunately, that leads to the existence of this file to include everything but that file.

# First the sub-modules.
require "./internals"
require "./dsl"
require "./matchers"
require "./formatters"

# Then all of the top-level types.
require "./example"
require "./runnable_example"
require "./pending_example"

require "./example_hooks"
require "./example_group"

require "./expectation"
require "./expectation_failed"
require "./test_results"
require "./runner"

require "./result"
require "./successful_result"
require "./pending_result"
require "./failed_result"
require "./errored_result"
