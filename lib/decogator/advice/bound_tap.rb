module Decogator
  module Advice
    class BoundTap
      def initialize(inst, call, nxt)
        @inst_meth = inst.method(call)
        @next = nxt
      end

      def call(*args, &block)
        return_value = nil
        @inst_meth.call(&lambda { return_value = @next.call(*args, &block) })
        return_value
      end
    end
  end
end
