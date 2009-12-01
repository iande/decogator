module Decogator
  module Advice
    class Around
      def initialize(call)
        @call = call
      end

      def procify(inst, jp, &cb)
        arity = (inst.respond_to?(@call)) ? inst.method(@call).arity : 0
        if arity != 0
          lambda { inst.send(@call, jp, &cb) }
        else
          lambda { inst.send(@call, &cb) }
        end
      end
    end
  end
end
