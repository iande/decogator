module Decogator
  module Delegation
    def delegates(*args)
      opts = args.pop
      unless opts.is_a?(Hash) && (to = opts[:to])
        raise ArgumentError, "must specify a receiver for delegation with the :to option"
      end
      args.each do |meth|
        meth = meth.to_sym
        module_eval <<-EOS
          def #{meth}(*args, &block)
            #{to}.send(#{meth.inspect}, *args, &block)
          end
        EOS
      end
    end
  end
end
