module Decogator
  module Advice
    class Tap
      def initialize(call)
        @call = call
      end

      # The difference between this and around is subtle, but important
      # our lambda evaluates to the evaluation of the call back, not
      # itself.
      def procify(inst, jp, &cb)
        arity = (inst.respond_to?(@call)) ? inst.method(@call).arity : 0
        if arity != 0
          lambda do
            return_val = nil
            evcb = lambda { return_val = cb.call }
            inst.send(@call, jp, &evcb)
            return_val
          end
        else
          lambda do
            return_val = nil
            evcb = lambda { return_val = cb.call }
            inst.send(@call, &evcb)
            return_val
          end
        end
      end
    end
  end
end
