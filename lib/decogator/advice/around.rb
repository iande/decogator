module Decogator
  module Advice
    class Around
      def initialize(call)
        @call = call
      end

      def bind(inst, to_wrap)
        BoundAround.new(inst, @call, to_wrap)
      end
    end
  end
end
