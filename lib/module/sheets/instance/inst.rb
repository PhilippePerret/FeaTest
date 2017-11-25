# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    attr_reader :path
    attr_reader :step

    # Description de l'étape
    attr_reader :description

    def initialize fpath
      @path = fpath
    end

  end#/FeaTestSheet
end #/FeaTestModule
