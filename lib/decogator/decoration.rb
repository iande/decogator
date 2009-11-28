module Decogator
  module Decoration
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
                self.class.with_advice_for(#{meth.inspect}, self)
              end
            EOS
          end
          @decogator_chain[meth].add(advice, call)
        end
      end
    end

    def with_advice_for(meth, inst, *args, &block)
      meth = meth.to_sym
      raise ArgumentError, "no advice for method: #{meth}" unless @decogator_chain.has_key?(meth)

    end

    class Decoratorz
      def initialize()
        @advice = {}
        @advice[:before] = []
        @advice[:after] = []
        @advice[:around] = []
      end

      def do_when(whence, call)
        @advice[whence] << call
      end
      
      def perform(receiver, &block)
        @advice[:before].each { |a| receiver.send(a) }
        ret = nil
        # I love lambdas!
        tapped = @advice[:tap_around].inject(lambda { ret = block.call }) do |acc, a|
          lambda { |adv| lambda { receiver.send(adv, &acc) } }.call(a)
        end
        @advice[:around].inject() do |acc, a|

        end
        @advice[:after].each { |a| receiver.send(a) }
        ret
      end
    end

    module Helpers
      def self.create_decogator_method(base, meth)
        return if (base.public_instance_methods|base.private_instance_methods|base.protected_instance_methods).include?("_decogated_#{meth}")
        meth = meth.to_sym
        base.class_eval <<-EOS
          def _decogated_#{meth}(*args, &block)
            self.class.with_advice_for(#{meth.inspect}, self) do
              _undecogated_#{meth}(*args, &block)
            end
          end
        EOS
        base.chain_alias meth, "_decogated_#{meth}", "_undecogated_#{meth}" rescue nil
      end
    end
  end
end
