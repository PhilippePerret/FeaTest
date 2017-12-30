=begin

  Fichier principal pour le test des tests

=end
describe 'Test d’une applcation' do
  before :all do
    require_module 'test'
  end
  describe 'FeaTest#build_and_run_tests' do
    it 'répond' do
      expect(apptest).to respond_to :build_and_run_tests
    end

  end

end
