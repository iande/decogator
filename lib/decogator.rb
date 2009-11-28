require 'decogator/chained_alias'
require 'decogator/delegation'
require 'decogator/decoration'

module Decogator
  def self.included(base)
    #base.extend(Decogator::ChainedAlias)
    #base.extend(Decogator::ChainedAlias::CollisionPrevention)
    base.extend(Decogator::Delegation)
    base.extend(Decogator::Decoration)
  end
end