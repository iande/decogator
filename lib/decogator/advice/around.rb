module Decogator
  module Advice
    class Around
      def initialize(call)
        @call = call
      end

      def join(inst, jp)
        arity = (inst.respond_to?(@call)) ? inst.method(@call).arity : 0
        JoinPoint.new(jp, (arity == 0) ? lambda { inst.send(@call, &jp) } : lambda { inst.send(@call, jp) })
      end
    end
  end
end
