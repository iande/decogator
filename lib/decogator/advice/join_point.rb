module Decogator
  module Advice
    class JoinPoint
      include Decogator::Delegation
      delegates :args, :params, :parameters,
        :arguments, :'[]=', :'[]', :block, :to => :'@parent'

      def initialize(parent, proc)
        @parent = parent
        @proc = proc
      end
      
      def call
        @proc.call
      end

      def to_proc
        @proc
      end
    end
  end
end
