# Make sure this files directory is on the $LOAD_PATH
lib_path = File.expand_path(File.dirname(__FILE__)+"../..")
puts lib_path
unless $LOAD_PATH.include?(lib_path)
  $LOAD_PATH << lib_path
end

# Add the macos llvm brew directory to the ffi search path
require 'ffi'

# Add the correct search path for llvm (on mac from brew)
FFI::DynamicLibrary::SEARCH_PATH.unshift(`brew --prefix llvm@17`.strip + "/lib")


require 'parser/parser'
require 'codegen/visitor'

parser = StoutLang::Parser.new

code = File.read(ARGV[0])

ast = parser.parse(code)

Visitor.new(ast, ARGV[1], ARGV[2] == '1')
