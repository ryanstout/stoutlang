# Make sure this files directory is on the $LOAD_PATH
lib_path = File.expand_path(File.dirname(__FILE__)+"../..")
unless $LOAD_PATH.include?(lib_path)
  $LOAD_PATH << lib_path
end

require 'stoutlang'
require 'codegen/visitor'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('--ir', 'Dump the LLVM IR') do |v|
    options[:ir] = v
  end

  opts.on('--ast', 'Print the AST') do |v|
    options[:ast] = v
  end

  opts.on('--lib', 'Create a library instead of an app') do |v|
    options[:lib] = v
  end

  opts.on('--aot', 'Ahead of time compile the code') do |v|
    options[:aot] = v
  end

  opts.on('-O', '--optimization LEVEL', 'Set optimization level') do |v|
    options[:o] = v
  end
end.parse!

parser = StoutLang::Parser.new

input_file_path = ARGV[0]
output_file_path = ARGV[1]

if !input_file_path || (options[:aot] && !output_file_path)
  puts "Usage: ./run/build <input_file> <output_file>"
  exit
end

code = File.read(input_file_path)

# For now, just inject core
ast = parser.parse(code)

Visitor.new(ast, input_file_path, options).generate(output_file_path)
