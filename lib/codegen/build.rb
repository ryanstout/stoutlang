# Make sure this files directory is on the $LOAD_PATH
lib_path = File.expand_path(File.dirname(__FILE__)+"../..")
unless $LOAD_PATH.include?(lib_path)
  $LOAD_PATH << lib_path
end

require 'stoutlang'
require 'codegen/visitor'

parser = StoutLang::Parser.new

input_file_path = ARGV[0]
code = File.read(input_file_path)

ast = parser.parse(code)

Visitor.new(ast, input_file_path).generate(ARGV[1], ARGV[2] == '1')
