module StoutLang
  class BaseType < StoutLang::Ast::AstNode
    def self.prepare
      # noop
    end

    def type
      type = Type.new(self.class.name.split("::").last)
      type.parent = self
      type
    end

    def mangled_name
      self.class.name.split("::").last
    end

    def self.mangled_name
      self.name.split("::").last
    end

    # A single line version of inspect for displaying the function signature in a limited amount of space
    def inspect_small
      mangled_name
    end
  end
end
