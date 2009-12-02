module Decogator
  module Advice
    class BoundAround
      def initialize(inst, call, nxt)
        @inst_meth = inst.method(call)
        @next = nxt
      end
      
      def call(*args, &block)
        proc = lambda { |*p| p = args if p.size == 0; @next.call(*p, &block) }
        unless @inst_meth.arity == 0
          @inst_meth.call(block, *args, &proc)
        else
          @inst_meth.call(&proc)
        end
      end
    end
  end
end
