module Decogator
  module Decoration
    module ClassMethods
      [:before, :around, :after, :tap].each do |advice|
        module_eval <<-EOS
          def #{advice}(*args, &block)
            __process_advice__(#{advice.inspect}, *args, &block)
          end
        EOS
      end
      
      def __process_advice__(advice, *args, &block)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        decorator = block || opts[:call] || raise(ArgumentError, "no advice implementation specified")
        raise ArgumentError, "#{advice} advice cannot be implemented with a block" if [:tap, :around].include?(advice) && block_given?
        args.each { |meth| __advise_method__(meth, advice, decorator) }
      end

      def __advice_chain__
        unless @__decogator_chain__
          @__decogator_chain__ = Hash.new do |hash, key|
            prior = ancestors.detect { |a| a.respond_to?(:__advice_chain__) && a.__advice_chain__.has_key?(key) }
            init_with = prior ? prior.__advice_chain__[key] : instance_method(key)
            hash[key] = Decogator::Advice::Chain.new(init_with)
          end
        end
        @__decogator_chain__
      end

      def __advise_method__(meth, advice, decorator)
        meth = meth.to_sym
        __advice_chain__[meth].send("add_#{advice}", decorator)
        module_eval <<-EOS
          def #{meth}(*args, &block)
            #{self}.__advice_chain__[#{meth.inspect}].call(self, *args, &block)
          end
        EOS
      end

      def method_added(meth)
        unless __advice_chain__.has_key?(meth)
          if ancestors.detect { |a| a.respond_to?(:__advice_chain__) && a.__advice_chain__.has_key?(meth) }
            __advice_chain__[meth]= Decogator::Advice::Chain.new(instance_method(meth))
          end
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
