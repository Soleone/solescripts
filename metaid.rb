class Object
  # the singleton class of this object's instance
  def metaclass
    class << self
      self
    end
  end
  
  def meta_eval(&block)
    metaclass.instance_eval &block
  end
  
  # adds methods to a metaclass
  def meta_def(name, &block)
    meta_eval { define_method(name, &block) }
  end
end

class Module
  # defines an instance method within a module
  def module_def(name, &block)
    module_eval { define_method(name, &block) }
  end
end

class Class
  alias class_def module_def
end