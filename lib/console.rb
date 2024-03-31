# The StoutLang console

# Add main path to load path
main_path = File.expand_path(File.dirname(__FILE__) + "/..")
unless $LOAD_PATH.include?(main_path)
  $LOAD_PATH << main_path
  puts main_path
end

require 'stoutlang'
require 'readline'



class Console
  def initialize
    puts "StoutLang console"
    puts "Type 'exit' to quit"

    while line = Readline.readline('> ', true)
      break if line.nil? || line == "exit"
      if line =~ /\S/ # skip blank lines
        history.push(line) unless Readline::HISTORY.to_a.last == line

        print "stout> "
        input = line.chomp

        # Parse the line and run it
        parser = StoutLang.parse(input)

        puts parser.ast.inspect
        puts parser.ast.run
        break if input == "exit"
      end
    end
  end
end

Console.new
