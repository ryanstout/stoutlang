
module InfixChainAst
  def to_ast
    # Consume left to right
    # Start with the leftmost primary
    left = method_chain.to_ast
    elements[1].elements.each do |op_and_right|
      op, right = op_and_right.elements.map(&:to_ast)
      left = StoutLang::Ast::FunctionCall.new(op, [left, right], op_and_right.op)
    end

    return left
  end
end

module InfixUnaryChainAst
  def to_ast
    StoutLang::Ast::FunctionCall.new(op.to_ast, [expression.to_ast], op)
  end
end

module InfixOps
  def to_ast
    operator.text_value
  end
end
