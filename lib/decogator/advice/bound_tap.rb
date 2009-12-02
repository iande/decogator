module Decogator
  module Advice
    class BoundTap
      def initialize(inst, call, nxt)
        raise ArgumentError, "receiver class #{inst.class} does not respond to #{call}" unless inst.respond_to?(call)
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
