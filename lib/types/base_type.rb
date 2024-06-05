module StoutLang
  class BaseType
    def self.prepare
      # noop
    end

    def type
      assign_parent!(Type.new(self.class.name.split('::').last))
    end

    def mangled_name
      self.class.name.split('::').last
    end

    def self.mangled_name
      self.name.split('::').last
    end
  end
end
