# Make sure this files directory is on the $LOAD_PATH
unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))
  $LOAD_PATH << File.expand_path(File.dirname(__FILE__))
end

require 'parser/parser'

module StoutLang
  def self.parse(code, options={})
    parser = Parser.new

    parser.parse(code, options)

    return parser
  end
end
