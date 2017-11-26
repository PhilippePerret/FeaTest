# encoding: utf-8
module FeaTestModule
  def run
    CLI.parse
    case CLI.param(1)
    when 'help'
      help
    when 'check'
      CLI::PARAMS_ORDER[:file_path] = 1
      require_module 'check'
      check_and_display
    when 'build'
      CLI::PARAMS_ORDER[:file_path] = 1
      require_module 'build'
      build_all_files
    when 'rename'
      CLI::PARAMS_ORDER[:file_path] = 3
      require_module 'rename'
      rename CLI.param(2), CLI.param(3), CLI.param(4)
    else
      prepare_build_and_run_test
    end
  end


  def prepare_build_and_run_test
    require_module 'test'
    build_and_run_tests
  end

  # L'aide se compose de deux éléments :
  # - fichier lib/asset/aide.txt qui est renseigné dynamiquement et
  #   contient l'ensemble des informations requises
  # - le manuel en format manpage, utile pour la commande en ligne
  #
  def help
    require_module 'help'
    Help.display
  end

end #/module
