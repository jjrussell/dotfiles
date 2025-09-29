#!/usr/bin/env ruby


puts "Creating file from " + ARGV[0]

file=File.new(ARGV[0], "r")
line_number = ARGV[1].to_i

if ! line_number.is_a?(Numeric)
  puts "Second argument must be the line number you want removed from the file: " + line_number
  exit 1
end

tmp_file=File.new(file.path + ".tmp", "w+")

if ! File.exists?(file)
  puts "File " + file.path + " does not exist"
  exit 1
else
  puts "File " + file.path + " exists"
end

number = 0
file.each_line{ |line|
  number += 1
  if number != line_number
    tmp_file.write line
  else
    puts "skipping line " + number.to_s
  end
  
}
file.close
tmp_file.close

puts "Renameing " + tmp_file.path + " to " + file.path
File.rename(tmp_file.path, file.path)
puts "So long and thanks for all the fish"
