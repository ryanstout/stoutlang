# Make sure this files directory is on the $LOAD_PATH
lib_path = File.expand_path(File.dirname(__FILE__)) + "/lib"
unless $LOAD_PATH.include?(lib_path)
  $LOAD_PATH << lib_path
end

require 'parser/parser'

module StoutLang
  def self.parse(code, options={})
    parser = Parser.new

    parser.parse(code, options)

    return parser
  end
end
