# encoding: utf-8
=begin
   Module principal qui lance les tests

=end
module FeaTestModule

  # Méthode principal
  def build_and_run_tests
    require_module 'validation'
    featest_valide?
    Dir.chdir(main_folder) do
      prepare
      build_test
      run_test
    end
  end

end #/FeaTestModule
