module Decogator
  module Advice
    class Chain
      def initialize(method)
        @method = method
        @chain = []
      end

      def call(inst, *args, &block)
        
        @method.bind(inst).call(*args, &block)
      end

      def add(advice, call)
        adv_name = advice.to_s.gsub(/(\b|_)(\w)/) { $2.upcase }
        @chain << self.class.const_get(adv_name).new(call)
      end
    end
  end
end
