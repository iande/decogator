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
            @decogator_chain ||= {}

            # If the method does not currently exist, write in some stuff
            # to defer until it is defined.
            unless @decogator_chain.has_key?(meth)
              @decogator_chain[meth] = Decogator::Advice::Chain.new(instance_method(meth))
              module_eval <<-EOS
                def #{meth}(*args, &block)
                  self.class.with_advice_for(#{meth.inspect}, self, *args, &block)
                end
              EOS
            end
            @decogator_chain[meth].send("add_#{advice}", call)
          end
        end
      end

      def with_advice_for(meth, inst, *args, &block)
        meth = meth.to_sym
        raise ArgumentError, "no advice for method: #{meth}" unless @decogator_chain.has_key?(meth)
        @decogator_chain[meth].call(inst, *args, &block)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end
