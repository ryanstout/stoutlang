
module InfixChainAst
  def to_ast
    # Consume left to right
    # Start with the leftmost primary
    left = method_chain.to_ast
    elements[1].elements.each do |op_and_right|
      op, right = op_and_right.elements.map(&:to_ast)
      args = [left, right]
      left = StoutLang::Ast::FunctionCall.new(op, args, op_and_right.op).assign_parent!(args)
    end

    return left
  end
end

module InfixUnaryChainAst
  def to_ast
    args = [expression.to_ast]
    StoutLang::Ast::FunctionCall.new(op.to_ast, args, op).assign_parent!(args)
  end
end

module InfixOps
  def to_ast
    operator.text_value
  end
end
