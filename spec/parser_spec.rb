require 'spec_helper'

describe StoutLangParser do
  it 'should parse a simple program' do
    # code = <<-END
    # a = 5
    # # a.something(arg1=5)
    # END

    code = <<-END
    a.method_call().other_call()
    END

    code = code.strip
    puts code
    puts "----------------"

    ast = Ast.new.parse(code)

    # puts ast.inspect

    # c = ast.find {|e| e.is_a?(StoutLang::Comment) }

    binding.irb
  end
end