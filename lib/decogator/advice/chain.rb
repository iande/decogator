module Decogator
  module Advice
    class Chain
      def initialize(method)
        @method = method
        @before = []
        @after = []
        @around = []
      end

      def call(inst, *args, &block)
        params = @before.inject([args, block]) { |acc, b| b.call(inst, *acc[0], &acc[1]) }
        @after.inject(@around.inject(@method.bind(inst)) { |acc, r|
          r.bind(inst, acc) }.call(*params[0], &params[1])) { |acc, a| a.call(inst, acc) }
      end

      def bind(obj)
        BoundChain.new(obj, self)
      end

      def add_before(call)
        @before.unshift(Before.new(call))
      end

      def add_after(call)
        @after.push(After.new(call))
      end

      def add_around(call)
        @around.push(Around.new(call))
      end

      def add_tap(call)
        @around.push(Tap.new(call))
      end
    end
  end
end
