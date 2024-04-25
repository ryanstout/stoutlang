# Add the root of the project to the load path
$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'stoutlang'
require 'pry' # binding.irb has some issues
require 'rspec_custom_formatter'

include StoutLang # add Parser to the namespace
include StoutLang::Ast # add Ast classes


RSpec.configure do |config|
  # Other configuration settings
  config.add_formatter RspecCustomFormatter
end
