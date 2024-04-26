# Helper class to take in a path to a file and compile it and all of it's imports.
require 'parser/parser'

module StoutLang
  class Compiler

    def self.compile(input_file_path, output_file_path, options={})
      puts "Building #{input_file_path}"
      ast = Parser.new.parse(File.read(input_file_path))
      Visitor.new(ast, input_file_path, options).generate(output_file_path)
    end
  end
end
