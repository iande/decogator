module Decogator
  module Advice
    class Before
      def initialize(call)
        @call = call
      end

      def call(inst, *args, &block)
        caller = (@call.is_a?(Proc)) ? @call : inst.method(@call)
        unless caller.arity == 0
          caller.call(*args, &block)
        else
          caller.call
          [args, block]
        end
      end
    end
  end
end
