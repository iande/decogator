module Decogator
  module Advice
    class After
      def initialize(call)
        @call = call
      end

      def call(inst, rval)
        caller = (@call.is_a?(Proc)) ? @call : inst.method(@call)
        unless caller.arity == 0
          caller.call(rval)
        else
          caller.call
          rval
        end
      end
    end
  end
end
