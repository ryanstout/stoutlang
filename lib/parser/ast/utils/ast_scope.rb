# require 'codegen/constructs/construct'

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
    return scope[identifier].last if scope && scope.key?(identifier)

    if parent
      return parent.lookup_identifier(identifier)
    end

    nil
  end

  # Similar to lookup_identifier, but walks up the parent scopes until it finds a matching function
  # Matches based on the arguments also.
  #
  # NOTE: C functions are always matched (ignoring arguments)
  def lookup_function(identifier, arg_types=nil)
    if scope && scope.key?(identifier)
      ids = scope[identifier]

      ids.reverse.each do |id|
        if id.is_a?(CPrototype) || (id.is_a?(Class) && id < StoutLang::Construct)
          # CPrototypes and Constructs only match on name not arguments (atm)
          return id
        else
          if id.is_a?(Def)
            # Only match a Def/DefPrototype if the arguments match
            id_arg_types = id.args.map {|i| i.type_sig.type_val }
            # puts "Compare: #{identifier} - #{id_arg_types.inspect} == #{arg_types.inspect}"
            if id_arg_types == arg_types
              return id
            end
          else
            if arg_types.size == 0
              # We can match on non-def's if there's no arguments (see Identfiier#resolve)
              return id
            end
          end
        end
      end
    end

    if parent
      # Walk up the chain
      return parent.lookup_function(identifier, arg_types)
    end

    return nil
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

  def inspect_scope(first=true)
    if first
      puts "--- Scope ---"
    end
    # Print each identifier in the current scope, then walk up the chain and do the same
    if scope
      scope.each do |k, v|
        puts "#{k} => #{v}"
      end
    end

    if parent
      parent.inspect_scope(false)
    end
  end

end
