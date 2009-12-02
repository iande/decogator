module Decogator
  module Advice
    class BoundChain
      def initialize(binding, chain)
        @binding = binding
        @chain = chain
      end

      def call(*args, &block)
        @chain.call(@binding, *args, &block)
      end
    end
  end
end
