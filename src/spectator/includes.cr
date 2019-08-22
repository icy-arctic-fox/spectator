# This file includes all source files *except* `should.cr`.
# The `should.cr` file contains the optional feature for using should-syntax.
# Since this is disabled by default, we don't include all files.
# Including all files with a wildcard would accidentally enable should-syntax.
# Unfortunately, that leads to the existence of this file to include everything but that file.

# FIXME: Temporary (hopefully) require statement to workaround Crystal issue #7060.
# https://github.com/crystal-lang/crystal/issues/7060
# The primary issue seems to be around OpenSSL.
# By explicitly including it before Spectator functionality, we workaround the issue.
require "openssl"

# First the sub-modules.
require "./internals"
require "./dsl"
require "./expectations"
require "./matchers"
require "./formatting"

# Then all of the top-level types.
require "./example_component"
require "./example"
require "./runnable_example"
require "./pending_example"
require "./dummy_example"

require "./example_conditions"
require "./example_hooks"
require "./example_group"
require "./nested_example_group"
require "./root_example_group"

require "./config"
require "./config_builder"
require "./config_source"
require "./command_line_arguments_config_source"

require "./example_filter"
require "./source_example_filter"
require "./line_example_filter"
require "./name_example_filter"
require "./null_example_filter"
require "./composite_example_filter"

require "./example_failed"
require "./expectation_failed"
require "./test_suite"
require "./report"
require "./profile"
require "./runner"

require "./result"
require "./finished_result"
require "./successful_result"
require "./pending_result"
require "./failed_result"
require "./errored_result"

require "./source"
require "./example_iterator"
