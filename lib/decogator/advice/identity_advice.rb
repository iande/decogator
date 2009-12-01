module Decogator
  module Advice
    class IdentityAdvice
      def initialize(bound_method, params)
        @method = bound_method
        @args = params[0]
        @block = params[1]
      end

      def call()
        @method.call(*@args, &@block)
      end

      def args
        @args
      end

      def block
        @block
      end

      def block=(proc)
        raise ArgumentError, "given argument must be a proc" unless proc.is_a?(Proc)
        @block = proc
      end
      alias_method :params, :args
      alias_method :arguments, :args
      alias_method :parameters, :args

      def to_proc()
        lambda { call() }
      end
    end
  end
end
