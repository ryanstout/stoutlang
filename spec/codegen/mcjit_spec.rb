require 'spec_helper'
require 'codegen/mcjit'

def create_square_function_module
  LLVM::Module.new('square').tap do |mod|
    mod.functions.add(:square, [LLVM::Int], LLVM::Int) do |fun, x|
      fun.basic_blocks.append.build do |builder|
        n = builder.mul(x, x)
        builder.ret(n)
      end
    end

    mod.verify!
  end
end

describe "Jit" do
  it 'should instantialize and let you add LLVM modules' do
    @jit = MCJit.new
    code = <<-END
    def hello() -> Int {
      %> "Hello Jit World!"
      5
    }
    END

    # ast = Parser.new.parse(code)

    # visitor = Visitor.new(ast)

    mod = create_square_function_module
    @jit.add_module(mod)

    result = @jit.run_function(mod.functions['square'], 5)
    expect(result.to_i).to eq(25)
  end
end
