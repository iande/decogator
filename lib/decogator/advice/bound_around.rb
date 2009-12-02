module Decogator
  module Advice
    class BoundAround
      def initialize(inst, call, nxt)
        raise ArgumentError, "receiver class #{inst.class} does not respond to #{call}" unless inst.respond_to?(call)
        @inst_meth = inst.method(call)
        @next = nxt
      end
      
      def call(*args, &block)
        unless @inst_meth.arity == 0
          @inst_meth.call(@next, *args, &block)
        else
          # Allows us to yield with no args, and call the underlying
          # method with unchanged parameters.
          @inst_meth.call(&lambda { |*p|
            p = args if p.size == 0
            @next.call(*p, &block)
          })
        end
      end
    end
  end
end
