# encoding: utf-8
module FeaTestModule; end
class FeaTest
  include FeaTestModule

  class << self
    attr_accessor :current
  end #/<< self

  def initialize
    self.class.current = self
  end
end #/FeaTest
