# encoding: utf-8
module FeaTestModule ; end
class FeaTest
  def online?
    !offline?
  end
  def offline?
    @is_offline ||= !CLI.option(:online)
  end

end #/FeaTest

