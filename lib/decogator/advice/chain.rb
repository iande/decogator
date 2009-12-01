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
        @after.inject(@around.inject(IdentityAdvice.new(@method.bind(inst),
            @before.inject([args, block]) { |acc, b|
              b.call(inst, *acc[0], &acc[1])
            })) { |acc, r| r.join(inst, acc) }.call) { |acc, a|
          a.call(inst, acc)
        }
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
