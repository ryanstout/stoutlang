module StoutLang
  class BaseType < StoutLang::Ast::AstNode
    def self.prepare
      # noop
    end

    def type
      type = Type.new(self.class.name.split('::').last)
      type.parent = self
      type
    end

    def mangled_name
      self.class.name.split('::').last
    end

    def self.mangled_name
      self.name.split('::').last
    end
  end
end
