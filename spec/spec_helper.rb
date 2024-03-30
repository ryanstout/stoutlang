# Add the root of the project to the load path
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'parser/parser'

include StoutLang # add Parser to the namespace
include StoutLang::Ast # add Ast classes
