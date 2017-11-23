# encoding: utf-8
=begin
   Module principal qui lance les tests

=end
module FeaTestModule

  # Méthode principal
  def build_and_run_tests
    featest_valide?
    Dir.chdir(main_folder) do
      prepare
      build_test
      run_test
    end
  end

  # Retourne TRUE si on trouve à l'adresse voulue (la courante ou celle
  # passée en argument) la hiérarchie qu'on s'attend à trouver. Sinon
  # indique l'erreur et permet de la corriger.
  def featest_valide?
    spec_folder = File.join(main_folder,'spec')
    feat_folder = File.join(spec_folder, 'features')
    {
      spec: spec_folder, features: feat_folder,
      featest: featest_folder, sheets: sheets_folder, steps: steps_folder
    }.each do |key, fpath|
      File.existsOrRaise(fpath, ERRMSG["folder_#{key}_required".to_sym])
    end
  end
end #/FeaTestModule
