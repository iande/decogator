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
        params = @before.inject([args, block]) do |acc, b|
          b.call(inst, *acc[0], &acc[1])
        end
        join_point = IdentityAdvice.new(@method.bind(inst), params)
        return_value = @around.inject(join_point) do |acc, r|
          r.procify(inst, join_point, &acc)
        end.call
        @after.inject(return_value) { |acc, a| a.call(inst, acc) }
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
