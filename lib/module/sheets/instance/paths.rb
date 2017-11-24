# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    # Le dossier de l'étape, avant ou sans user défini
    def steps_folder as_user = nil
      @steps_folder ||= File.join(main_steps_folder, step.downcase)
      as_user ? File.join(@steps_folder, as_user.to_s) : @steps_folder
    end

    def main_steps_folder
      @main_steps_folder ||= FeaTest.current.steps_folder
    end

  end #/FeaTestSheet
end #/FeaTestModule
