# encoding: utf-8
module FeaTestModule

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
      spec: spec_folder, features: feat_folder,
      featest: featest_folder, sheets: sheets_folder, steps: steps_folder
    }.each do |key, fpath|
      err_msg = ERRMSG["folder_#{key}_required".to_sym]
      if only_check
        File.exist?(fpath) || error(err_msg % fpath)
      else
        File.existsOrRaise(fpath, err_msg)
      end
    end
    return valide
  end

end #/FeaTestModule
