# encoding: utf-8
module FeaTestModule
  def run
    # puts "Dans FeaTestModule#run, '.' = #{File.expand_path('.')}"
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
    data_ok_for_test? || return
    require_module 'test'
    build_and_run_tests
  end

  # Cette méthode vérifie que les données sont suffisantes pour un test
  # et produit une erreur aidée dans le cas contraire
  def data_ok_for_test?
    CLI.option(:as) || CLI::ARGS[:options].merge!(as: 'all')
    CLI.option(:steps)  || raise("Pour le moment, il faut définir explicitement les étapes à exécuter à l'aide de l'option `--steps=...`")
    #puts "steps: #{CLI.option(:steps)}"
   return true
  rescue Exception => e
    error e.message
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
