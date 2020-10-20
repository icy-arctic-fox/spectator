# This file includes all source files *except* `should.cr`.
# The `should.cr` file contains the optional feature for using should-syntax.
# Since this is disabled by default, we don't include all files.
# Including all files with a wildcard would accidentally enable should-syntax.
# Unfortunately, that leads to the existence of this file to include everything but that file.

require "./command_line_arguments_config_source"
require "./config_builder"
require "./config"
require "./dsl"
