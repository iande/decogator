require 'decogator/delegation'
require 'decogator/decoration'
require 'decogator/advice'

module Decogator
  def self.included(base)
    base.send :include, Decogator::Decoration
    base.send :include, Decogator::Delegation
  end
end