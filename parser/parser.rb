# require 'parser/parse_nodes/parse_nodes'
require 'parser/ast/ast_node'
Dir["#{File.dirname(__FILE__)}/ast/*.rb"].each {|file| require file }

module StoutLang
  # include ParseNodes

end
