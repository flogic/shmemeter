require 'active_support'

class Module
  def delegate_with_method_name_change_or_missing_target(*args)
    methods = args.dup
    options = methods.pop 
    
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end
    
    value_set = false
    value = nil
    if options.has_key?(:missing_target)
      raise ArgumentError, "Can only delegate one method at a time when providing a value to use when the target is missing" unless methods.size == 1
      value = options[:missing_target]
      value_set = true
      
      unless options.has_key?(:as)
        target_method = methods.first
        delegate target_method, options.merge(:as => target_method)
        return
      end
    end
    
    if as = options[:as]
      raise ArgumentError, "Can only delegate one method at a time when changing target method name" unless methods.size == 1
      methods.each do |method|
        method_lines = ["def #{method}(*args, &block)",
                        "  #{to}.__send__(#{as.inspect}, *args, &block)",
                        'end'
                       ]
        if value_set
          method_lines[1]    = '  ' + method_lines[1]
          method_lines[1,0]  = "  if #{to}"
          method_lines[-1,0] = ['  else',
                                "    #{value.inspect}",
                                '  end'
                               ]
        end
        module_eval(method_lines.join("\n"), "(__DELEGATION__)", 1)
      end
    else
      delegate_without_method_name_change_or_missing_target(*args)
    end
  end
  alias_method_chain :delegate, :method_name_change_or_missing_target
end
