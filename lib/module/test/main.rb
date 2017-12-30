# encoding: utf-8
=begin
   Module principal qui lance les tests

=end
module FeaTestModule

  # Méthode principale
  #
  # Si tout se passe bien, la méthode retourne true, sinon false.
  def build_and_run_tests
    require_module 'validation'
    featest_valide? || (return false)
    Dir.chdir(main_folder) do
      prepare
      build_test
      run_test
    end
    return true
  end

end #/FeaTestModule
