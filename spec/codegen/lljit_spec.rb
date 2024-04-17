# Disable for now, we'll move to ORC Jit when LLVM docs get updated
# require 'spec_helper'
# require 'codegen/lljit'

# require 'llvm'
# require 'llvm/core'
# def create_square_function_module
#   LLVM::Module.new('square').tap do |mod|
#     mod.functions.add(:square, [LLVM::Int], LLVM::Int) do |fun, x|
#       fun.basic_blocks.append.build do |builder|
#         n = builder.mul(x, x)
#         builder.ret(n)
#       end
#     end

#     mod.verify!
#   end
# end

# describe "Jit" do
#   it 'should instantialize and let you add LLVM modules' do
#     @jit = Jit.new
#     code = <<-END
#     def hello() -> Int {
#       %> "Hello Jit World!"
#       5
#     }
#     END

#     # ast = Parser.new.parse(code)

#     # visitor = Visitor.new(ast)
#     # puts visitor.inspect

#     mod = create_square_function_module
#     puts "Module: #{mod.inspect}"
#     @jit.add_module(mod)


#   end
# end
