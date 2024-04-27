module StoutLang
  module NameMangle

    # Returns the c safe mangled name option
    #
    # Mangled func names in stoutlang have the following:
    # 'sl', stoutlang version, '__', function name, '__', arg types, '__', return type
    #
    #
    # The return type doesn't need to be there, but we add it for clarity
    def c_safe_mangled_name(obj)
      # Get the mangled name of the function
      @c_mangled_name ||= begin
        mangled_args = obj.args.map do |arg|
          arg.type_sig.mangled_name
        end.join('_')
        "sl1_#{obj.name}__#{mangled_args}__#{obj.return_type.mangled_name}"
      end
    end

    # To make life easier, we use the stoutlang function signature (the full signature) as the mangled name.
    # We also prefix with 'sl', and the stoutlang verison (1 atm), '.'
    #
    # NOTE: self should be a Def
    def mangled_name
      @mangled_name ||= begin
        mangled_args = self.args.map do |arg|
          arg.type_sig.mangled_name
        end.join(',')
        "sl1.#{self.name}(#{mangled_args})->#{self.return_type.mangled_name}"
      end
    end

    # Lets you look up a function by string args and return type
    def self.mangle_name(name, args, return_type)
      "sl1.#{name}(#{args.join(',')})->#{return_type}"
    end

    # Takes a mangled function call name and extracts
    def unmangle(mangled_name)
      if mangled_name[0..3] != 'sl1.'
        # Looks like a C export, just return the name
        return mangled_name, nil, nil
      else
        match = mangled_name.match(/sl1\.(.*)\((.*)\)->(.*)/)
        name = match[1]
        args = match[2].split(',')
        return_type = match[3]
        return name, args, return_type
      end
    end
  end
end
