=begin

  Cette fiche de test doit servir d'essai pour tester les retours
  de l'application FeaTest.
  L'idée est :
  * de pouvoir créer une application de test (apptest)
  * de jouer `featest` en mode console
  * de voir si le retour est correct.

  On commence par des choses très simples, avec par exemple une
  application qui ne possède qu'une seule méthode.

=end

def featest options
  `bash -c ". #{Dir.home}/.bash_profile;shopt -s expand_aliases\ncd #{apptest.app_folder};featest #{options}" 2>&1`
end


describe 'Retour de test' do
  before :all do
    # Préparer l'application
    #
    build_app_test
  end

  describe 'Test d’une simple méthode' do
    it 'produit le résultat attendu' do
      res = featest '--steps=all'
      log "RES: #{res}"
    end

  end
end
