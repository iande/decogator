module Decogator
  module Decoration
    module ClassMethods
      [:before, :around, :after, :tap].each do |advice|
        define_method advice do |*args|
          opts = args.pop
          raise ArgumentError, "no options specified" unless opts.is_a?(Hash)
          call = opts[:call] || raise(ArgumentError, "no call specified")
          args.each do |meth_name|
            meth = meth_name.to_sym

            defined_before = __advice_chain__.has_key?(meth)
            __advice_chain__[meth].send("add_#{advice}", call)
            unless defined_before
              module_eval <<-EOS
                def #{meth}(*args, &block)
                  self.class.__advice_chain__[#{meth.inspect}].call(self, *args, &block)
                end
              EOS
            end
          end
        end
      end

      def __advice_chain__
        unless @__decogator_chain__
          @__decogator_chain__ = Hash.new do |hash, key|
            prior = ancestors.detect { |a| a != self && a.respond_to?(:__advice_chain__) }
            init_with = if prior && prior.__advice_chain__.has_key?(key)
              prior.__advice_chain__[key]
            else
              instance_method(key)
            end
            hash[key] = Decogator::Advice::Chain.new(init_with)
          end
        end
        @__decogator_chain__
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
