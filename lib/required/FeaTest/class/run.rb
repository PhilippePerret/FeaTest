# encoding: utf-8
module FeaTestModule
  def run
    CLI.parse
    case CLI.param(1)
    when 'help'
      help
    else
      run_test
    end
  end


  def run_test
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
