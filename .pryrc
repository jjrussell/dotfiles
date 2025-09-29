def try_to_require(gem)
  require gem
rescue LoadError => e
  puts "Error loading gem #{gem}. #{e}. Moving on."
end

%w{ json date active_support/all table_print pp }.each do |gem|
  try_to_require(gem)
end

if defined?(PryDebugger) || defined?(Byebug)
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
end