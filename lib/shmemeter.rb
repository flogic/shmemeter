require 'active_support'

class Module
  def delegate_with_method_name_change(*args)
    methods = args.dup
    options = methods.pop 
    
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end
    
    if as = options[:as]
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
end
