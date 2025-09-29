# Stop lots of stack traces if we use irb with bundle
def try_require(package)
  loaded = true
  begin
    require package
  rescue LoadError,Exception => e
    loaded = false
    puts "Error loading #{package}. It was probably not in the bundle"
  end
  loaded
end

try_require 'redis'
try_require 'statsd'
try_require 'memcached'

try_require 'json'
try_require 'fileutils'
try_require 'rubygems'
try_require 'active_support'
try_require 'active_support/inflector'
try_require 'active_support/core_ext'
try_require 'yaml'
try_require 'pp'


try_require 'awesome_print'

if defined?(Pry)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  #Pry.commands.alias_command 'l', 'show-stack'

  try_require 'pry-stack_explorer'

  Pry.config.editor = proc { |file, line| "emacsclient #{file} +#{line}" }
end