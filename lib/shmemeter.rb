require 'active_support'

class Module
  def delegate_with_method_name_change(*args)
    methods = args.dup
    options = methods.pop 
    
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end
    
    if as = options[:as]
      raise ArgumentError, "Can only delegate one method at a time when changing target method name" unless methods.size == 1
      methods.each do |method|
        module_eval(<<-EOS, "(__DELEGATION__)", 1)
          def #{method}(*args, &block)
            #{to}.__send__(#{as.inspect}, *args, &block)
          end
        EOS
      end
    else
      delegate_without_method_name_change(*args)
    end
  end
  alias_method_chain :delegate, :method_name_change
  
  def delegate_with_missing_target(*args)
    methods = args.dup
    options = methods.pop
    
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end
    
    if options.has_key?(:missing_target)
      raise ArgumentError, "Can only delegate one method at a time when providing a value to use when the target is missing" unless methods.size == 1
      value = options[:missing_target]
      methods.each do |method|
        module_eval(<<-EOS, "(__DELEGATION__)", 1)
          def #{method}(*args, &block)
            if #{to}
              #{to}.__send__(#{method.inspect}, *args, &block)
            else
              #{value.inspect}
            end
          end
        EOS
      end
    else
      delegate_without_missing_target(*args)
    end
  end
  alias_method_chain :delegate, :missing_target
end
