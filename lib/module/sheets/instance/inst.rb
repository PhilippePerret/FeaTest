# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    attr_reader :path
    attr_reader :step
    attr_reader :step_description

    def initialize fpath
      @path = fpath
    end

  end#/FeaTestSheet
end #/FeaTestModule
