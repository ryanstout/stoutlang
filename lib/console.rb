# The StoutLang console

# Add main path to load path
main_path = File.expand_path(File.dirname(__FILE__))
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

    # Create a root and starting block
    root = StoutLang::Ast::Struct.new(StoutLang::Ast::Type.new("Root"), StoutLang::Ast::Exps.new([]), nil)

    while line = Readline.readline('> ', true)
      break if line.nil? || line == "exit"
      if line =~ /\S/ # skip blank lines
        history.push(line) unless Readline::HISTORY.to_a.last == line

        print "stout> "
        input = line.chomp

        # Parse the line and run it
        parser = StoutLang.parse(input, wrap_root: false)

        # After we parse, we add to the root block for the console
        parser.ast.parent = root
        root.add_expression(parser.ast)

        # prepare everything, then run it
        parser.ast.prepare

        puts parser.ast.inspect
        puts parser.ast.run
        break if input == "exit"
      end
    end
  end
end

Console.new
