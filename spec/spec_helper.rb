# Add the root of the project to the load path
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'parser/ast'
require 'parser/ast/ast_node'

include StoutLang::Ast
