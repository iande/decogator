module Decogator
  module Advice
    class Tap
      def initialize(call)
        @call = call
      end

      def bind(inst, to_wrap)
        BoundTap.new(inst, @call, to_wrap)
      end
    end
  end
end
