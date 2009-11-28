module Decogator
  module Advice
    class After
      def initialize(call)
        @call = call
      end
    end
  end
end
