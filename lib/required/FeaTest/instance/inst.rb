# encoding: utf-8
class FeaTest
  include FeaTestModule

  class << self
    attr_accessor :current
  end #/<< self

  def initialize
    self.class.current = self
  end

end #/FeaTest

