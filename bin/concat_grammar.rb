#!/usr/bin/env ruby
# Take all of the grammar files and put them into a single grammar file,
# This is used to ask GPT4 to create a textmate/vscode grammar file from
# the treetop grammars.

puts "The following is a ruby treetop grammar for a new programming language (called StoutLang). Create a tmLanguage.json file for the language by looking at the treetop grammar. The language is similar to ruby and should be highlighted like ruby. Try to match up concepts as closely as possbible."

puts ""
puts "Keep in mind that this language uses { and } instead of end."
puts "Don't forget to color strings and identifiers also."
puts ""
puts "The scopeName is `source.stoutlang`. The file extension is `.sl`."
puts ""

puts "```"
(Dir['lib/parser/grammar/*.treetop'] + ["lib/parser/parser.treetop"]).each do |file|
  code = File.read(file)
  # remove all { def to_ast .. end } to simplify it.
  code.gsub!(/\{[\n\s]*def to_ast[\n\s]*.*?[\n\s]*end[\n\s]*\}/m, '')

  # remove all grammar Name ... end to simplify it, keep the insides.
  code.gsub!(/grammar (.*?)\n(.*?)\nend/m, '\2')
  puts code
end
puts "```"

# puts "\n\nTo help, here is an example ruby tmLanguage.json file: \n```"
# puts File.read('bin/ruby.tmLanguage.json')
# puts "```"
