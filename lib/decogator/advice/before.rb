module Decogator
  module Advice
    class Before
      def initialize(call)
        @call = call
      end

      def call(inst, *args, &block)
        arity = (inst.respond_to?(@call)) ? inst.method(@call).arity : 0
        if arity != 0
          inst.send(@call, *args, &block)
        else
          inst.send(@call)
          [args, block]
        end
      end
    end
  end
end
