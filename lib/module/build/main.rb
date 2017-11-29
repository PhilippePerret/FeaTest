# encoding: utf-8
module FeaTestModule

  # Construit tous les fichiers manquants.
  def build_all_files

    require_module 'check'
    require_module 'sheets'

    FeaTestSheet.check

  end

end #/FeaTestModule
