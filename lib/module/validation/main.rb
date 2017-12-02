# encoding: utf-8
module FeaTestModule

  ERRMSG = {
    folder_main_required:     "Le dossier de l’application n’existe même pas… (`%s`)",
    folder_spec_required:     "Le dossier général RSpec devrait exister (`%s`)",
    folder_features_required: "Le dossier `spec/features` devrait exister (`%s`)",
    folder_featest_required:  "Le dossier `spec/features/featest` devrait exister (`%s`)",
    folder_sheets_required:   "Le dossier `featest/sheets` devrait exister (`%s`)",
    folder_steps_required:    "Le dossier des tests `featest/steps` devrait exister (`%s`)",

    folder_home_required:     "Le dossier `featest/steps/home` devrait exister (`%s`)",
    folder_signin_required:   "Le dossier `featest/steps/signin` devrait exister (`%s`)",
  }

  # Retourne TRUE si on trouve à l'adresse voulue (la courante ou celle
  # passée en argument) la hiérarchie qu'on s'attend à trouver. Sinon
  # indique l'erreur et permet de la corriger.
  #
  # @param {Hash} options
  #                 :check   si TRUE, on ne produit pas de raise en cas
  #                          d'absence de fichier, on signale une erreur
  #                          et on retourne FALSE.
  def featest_valide? options = Hash.new
    spec_folder = File.join(main_folder,'spec')
    feat_folder = File.join(spec_folder, 'features')
    only_check = !!options[:check]
    valide = true
    {
      main:       main_folder,
      spec:       spec_folder, 
      features:   feat_folder,
      featest:    featest_folder, 
      sheets:     sheets_folder, 
      steps:      steps_folder,
      home:       File.join(steps_folder,'home'),
      signin:     File.join(steps_folder, 'signin')
    }.each do |key, fpath|
      err_msg = ERRMSG["folder_#{key}_required".to_sym]
      if only_check
        File.exist?(fpath) || 
          begin
            valide = false
            @errors_count += 1
            error(err_msg % fpath)
        end
      else
        File.existsOrRaise(fpath, err_msg)
      end
    end
    return valide
  end

end #/FeaTestModule
