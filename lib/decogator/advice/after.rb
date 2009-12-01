module Decogator
  module Advice
    class After
      def initialize(call)
        @call = call
      end

      def call(inst, rval)
        arity = (inst.respond_to?(@call)) ? inst.method(@call).arity : 0
        if arity > 0
          inst.send(@call, rval)
        else
          inst.send(@call)
          rval
        end
      end
    end
  end
end
