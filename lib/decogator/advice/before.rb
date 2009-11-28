module Decogator
  module Advice
    class Before
      def initialize(call)
        @call = call
      end
    end
  end
end
