module Decogator
  module Advice
    class Tap
      def initialize(call)
        @call = call
      end

      # The difference between this and around is subtle, but important
      # our lambda evaluates to the evaluation of the call back, not
      # itself.
      def join(inst, jp)
        # Tap doesn't care about arity, it never sends the join point as anything
        # other than a block.
        JoinPoint.new(jp, lambda {
            return_val = nil
            evcb = lambda { return_val = jp.call }
            inst.send(@call, &evcb)
            return_val
        })
      end
    end
  end
end
