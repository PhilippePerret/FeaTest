=begin
  
  Préparation des fichiers de test en fonction de la 
  ligne de commande

=end
describe 'Préparation des tests' do
  before :all do
    require_module 'test'
    require_module 'sheets'
    CLI.parse
  end
  describe '#prepare' do
    it 'répond' do
      expect(apptest).to respond_to :prepare
    end
    
    context 'en cas d’application ne définissant pas les featest' do
      before :all do
        remove_app_test
      end
      it 'produit une erreur' do
        expect{apptest.prepare}.to raise_error RuntimeError
      end
    end

    context 'avec une application définissant bien les featests' do
      
      before :all do
        build_app_test
      end

      it 'la préparation ne produit pas d’erreur' do
        expect{apptest.prepare}.not_to raise_error
      end

      it 'les étapes relevées sont bien [:signin, :home]' do
        expect(apptest.steps_sequence).to eq([:signin, :home])
      end

      it 'les types d’users sont bien définis' do
        pending "Implémenter le test" 
      end
    end

    describe 'procède à une analyse correcte des feuilles de test' do
      before :all do
        FeaTest::FeaTestSheet.sheets_steps= nil
        #expect{apptest.prepare}.not_to raise_error
        apptest.prepare rescue nil
        FTMessage.show_messages
      end
      
      it 'a défini FeaTest::FeaTestSheet.sheets_steps' do
        # ======== VÉRIFICATION ICI =========
        shsteps = FeaTest::FeaTestSheet.sheets_steps
        notice "FeaTest::FeaTestSheet.sheets_steps = " + shsteps.inspect
        expect(shsteps).to_not be nil
      end
      
    end
  end
end
