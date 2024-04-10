# Make sure this files directory is on the $LOAD_PATH
lib_path = File.expand_path(File.dirname(__FILE__)) + "/lib"
unless $LOAD_PATH.include?(lib_path)
  $LOAD_PATH << lib_path
end

# Add the macos llvm brew directory to the ffi search path
require 'ffi'

# Add the correct search path for llvm (on mac from brew)
FFI::DynamicLibrary::SEARCH_PATH.unshift(`brew --prefix llvm@17`.strip + "/lib")

require 'llvm'
require 'llvm/core'

require 'parser/parser'

module StoutLang
  def self.parse(code, options={})
    parser = Parser.new

    parser.parse(code, options)

    return parser
  end
end
