#!/usr/bin/env ruby
# Take all of the grammar files and put them into a single grammar file,
# This is used to ask GPT4 to create a textmate/vscode grammar file from
# the treetop grammars.

Dir['parser/grammar/*.treetop'].each do |file|
  code = File.read(file)
  # remove all { def to_ast .. end } to simplify it.
  code.gsub!(/\{[\n\s]*def to_ast[\n\s]*.*?[\n\s]*end[\n\s]*\}/m, '')

  # remove all grammar Name ... end to simplify it, keep the insides.
  code.gsub!(/grammar (.*?)\n(.*?)\nend/m, '\2')
  puts code
end
