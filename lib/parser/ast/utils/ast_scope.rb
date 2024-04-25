module AstScope

  def scope
    nil
  end

  # Walk up the parents to find the nearest scope
  def current_scope
    if self.is_a?(Scope)
      return self
    elsif parent
      return parent.current_scope
    else
      raise "No parent scope available"
    end
  end

  def register_in_scope(identifier, node)
    # Finds the current scope and registers the node in it
    current_scope.register_identifier(identifier, node)
  end

  def lookup_identifier(identifier)
    return scope[identifier].first if scope && scope.key?(identifier)

    if parent
      return parent.lookup_identifier(identifier)
    end

    nil
  end

  def lookup_function(identifier, arg_types=nil)
    identifiers = lookup_identifier(identifier)
    return identifiers

    # Iterate through the identifiers and find if any match the arg_types
    # TODO: there is a faster way to do this probably
    identifiers.each do |ident|
      # if ident.is_a?(Def) || ident.is_a?(ExternFunc)
        # if ident.args.map(&:type_sig) == arg_types
          return ident
        # end
      # end
    end

    nil
  end

  def parent_scope
    # Walks up the parent chain until it finds a scope
    cur = parent
    while cur
      return cur if cur.is_a?(Scope)
      cur = cur.parent
    end

    nil
  end

end
