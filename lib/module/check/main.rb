# encoding: utf-8
module FeaTestModule

  def check_and_display

    # On va mettre dans cette liste toutes les aides qui devront être
    # affichées en fonction des erreurs trouvées. Ces aides permettront
    # de trouver des solutions rapides.
    @AIDES_REQUIRED = Hash.new

    # Introduction
    puts entete_check_and_display
    
    require_module 'validation'
    featest_valide?(check: true) || 
      begin
        puts "Poursuite du check impossible si tous les dossiers ne sont pas présents."
        return
    end

    config_file_valide?

    require_module 'sheets'
    FeaTestSheet.analyze_sheets(sheets_folder)

    check_etapes
  end
  
  ERRORS = {
    url_online_required:     "Le fichier config.rb devrait définir la méthode `FeaTestModule#url_online`",
    url_offline_required:    "Le fichier config.rb devrait définir la méthode `FeaTestModule#url_offline`",
    steps_sequence_required: "Le fichier config.rb doit définir la méthode `FeaTestModule#steps_sequence`",
    data_user_required:      "Le fichier config.rb doit définir la méthode `FeaTesModule#data_user(utype)`"
  }
  AIDE_PER_ERROR = Hash.new
  AIDE_PER_ERROR.merge! definition_affixe: <<~EOH
      (*) Définition de l'affixe
      ---------------------------
      L'affixe qui permet de définir le nom des fichiers se précise à la
      fin de la ligne de fonctionnalité (commençant par un astérisque)
      après les trois tirets, dans la feuille sheets/....ftest.

    EOH
  AIDE_PER_ERROR.merge! fichier_code_test: <<~EOH
      (**) Fichiers de code de test
      -----------------------------
      Pour créer facilement les fichiers contenant le code des tests, par
      fonctionnalité, il suffit de lancer la commande `featest build`.

    EOH
      

  # S'assure que le fichier congif.rb définisse bien ce qu'il doit
  # obligatoirement définir.
  def config_file_valide?
    existOrError(config_file_path) || return
    require config_file_path
    r = self.respond_to?(:url_online)     || error(ERRORS[:url_online_required])
    r = r && self.respond_to?(:url_offline)    || error(ERRORS[:url_offline_required])
    r = r && self.respond_to?(:steps_sequence) || error(ERRORS[:steps_sequence_required])
    r = r && self.respond_to?(:data_user)      || error(ERRORS[:data_user_required])
    r && notice("Le fichier config.rb définit toutes les méthodes utiles.")
  end
  
  # On teste toutes les étapes
  def check_etapes

    # Boucle sur chaque feuille featest (.ftest)
    FeaTestSheet::ETAPES.each do |ketape, etape|
      etape.check
    end

    unless @AIDES_REQUIRED.empty?
      puts "\n\n====================== AIDES UTILES =========================="
      @AIDES_REQUIRED.keys.each do |kaide|
        puts AIDE_PER_ERROR[kaide]
      end
      puts '='*90
      puts "\n\n\n"
    end
  end

  # Pour ajouter une aide à afficher:
  # FeaTest.current.add_aide_required(affixe)
  def add_aide_required kaide
    @AIDES_REQUIRED.merge!(kaide => true)
  end

  def entete_check_and_display
    <<~EOI

    #{'='*90}
    = CHECK DES FEATESTS #{Time.now}
    =

    EOI
  end
end #/FeaTestModule
