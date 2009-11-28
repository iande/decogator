module Decogator
  module ChainedAlias
    def chain_alias(desired_alias, for_method, alias_existing)
      alias_method alias_existing, desired_alias
      alias_method desired_alias, for_method
    end

    def chain_alias_preventing_collisions(desired, meth, existing)
      desired, meth, existing = [desired, meth, existing].map { |s| s.to_sym }
      existing_meths = public_instance_methods | private_instance_methods | protected_instance_methods
      raise ArgumentError, "a method named #{existing} already exists" if existing_meths.include?(existing.to_s)
      chain_alias_naively(desired, meth, existing)
    end

    def self.included(base)
      base.chain_alias :chain_alias, :chain_alias_preventing_collisions, :chain_alias_naively
    end
  end
end

::Module.send(:include, Decogator::ChainedAlias)