#!/usr/bin/env ruby

require "fileutils"

def add_exclusion(line)
  
  line.chomp!

  if line.match(/classpathentry.*kind=\"src\"/)
    puts "\n" + line + " is a src line entry"
    if line.match("excluding")
      # specially handle existing excludes
      if line.match(/excluding="\*\*\"/)
        puts "already excluding everything."
        return line
      elsif line.match(/excluding="[^"]*\.copyarea.db[^"]*"/)
        puts ".copyarea.db already excluded"
        return line
      else
        puts "Adding .copyarea.db exclude to existing line"
        line.sub!("excluding=\"", "excluding=\"**/.copyarea.db|")
        return line
      end
    else
      puts "adding new exclude in classpathentry"
      line.sub!("classpathentry ", "classpathentry excluding=\"**/.copyarea.db\" ")
      puts line
    end
  end

  return line
end

ARGV.each do |file|
  f = File.new(file)
  fnew = File.new(file + ".new", File::CREAT|File::TRUNC|File::RDWR)
  begin
    while (line = f.readline)
      line_with_exclude = add_exclusion(line) 
      puts "return : " + line_with_exclude
      fnew.puts(line)
    end
  rescue EOFError
    f.close
  end

  fnew.close
  
  FileUtils.cp(file, file + ".bak", :verbose => true)
  FileUtils.cp(file + ".new", file, :verbose => true)
end


