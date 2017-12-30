
describe "main.rb" do
  before :all do
    @app_path =  APP_TEST_PATH
    NOMBRE_ERREURS_MAIN_DOSSIERS = 8
    require_module 'check'
  end
  after :all do
    #remove_app_test
  end

  describe '#check_and_display (méthode principale)' do
    before :each do
      # On efface tous les messages qui ont pu être produit avant
      FTMessage.reset_messages
    end
    it 'répond' do
      expect(apptest).to respond_to :check_and_display
    end
    
    context 'avec un dossier featest valide pour l’application', only: false do
       it 'écrit un résultat positif' do
         build_app_test
         apptest.check_and_display
         FTMessage.show_messages
         expect(apptest.errors_count).to eq(0)
       end
    end

    context 'quand le dossier de l’app n’existe même pas' do
      before :all do
        remove_app_test
      end
      it 'affiche une erreur sur les dossiers', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS)
        mess = FTMessage.messages.join("\n")
        expect(mess).to include "Le dossier de l’application n’existe même pas"
      end
    end

    context 'quand le dossier spec n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{apptest.main_folder}` 
      end
      it 'affiche toutes les erreurs sur les dossiers s’ils n’existe pas (sauf app folder)', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 1)
        mess = FTMessage.messages.join("\n")
        expect(mess).to include "Le dossier général RSpec devrait exister"
      end
    end

    context 'quand le dossier spec/features n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec')}`
      end
      it 'affiche les erreurs sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 2)
        expect(FTMessage.messages.join("\n")).to include "Le dossier `spec/features` devrait exister"
      end
    end

    context 'quand le dossier spec/features/featest n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features')}`
      end
      it 'affiche les erreurs sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 3)
        expect(FTMessage.messages.join("\n")).to include "Le dossier `spec/features/featest` devrait exister"
      end
    end

    context 'quand le dossier spec/features/featest/sheets n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest')}`
      end
      it 'affiche les erreurs sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 4)
        expect(FTMessage.messages.join("\n")).to include "Le dossier `featest/sheets` devrait exister"
      end
    end

    context 'quand le dossier spec/features/featest/steps n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','sheets')}`
      end
      it 'affiche les erreurs sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 5)
        expect(FTMessage.messages.join("\n")).to include "Le dossier des tests `featest/steps` devrait exister"
      end
    end


    context 'quand le dossier spec/features/featest/steps/home n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','steps')}`
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','sheets')}`
      end
      it 'affiche les erreurs sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 6)
        expect(FTMessage.messages.join("\n")).to include "Le dossier `featest/steps/home` devrait exister"
      end
    end


    context 'quand le dossier spec/features/featest/steps/signin n’existe pas' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','steps','home')}`
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','sheets')}`
      end
      it 'affiche les erreurs sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 7)
        expect(FTMessage.messages.join("\n")).to include "Le dossier `featest/steps/signin` devrait exister"
      end
    end
    

    context 'quand le dossier existent tous' do
      before :all do
        remove_app_test
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','steps','home')}`
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','steps','signin')}`
        `mkdir -p #{File.join(apptest.main_folder, 'spec','features','featest','sheets')}`
      end
      it 'affiche aucune erreur sur les dossiers principaux', only: true do
        apptest.check_and_display
        expect(apptest.errors_count).to eq(NOMBRE_ERREURS_MAIN_DOSSIERS - 8)
        #expect(FTMessage.messages.join("\n")).to include "Le dossier `featest/steps/signin` devrait exister"
      end
    end
  end
  describe '#entete_check_and_display' do
    it 'répond' do
      expect(apptest).to respond_to :entete_check_and_display
    end
    it 'retourne un string avec le bon titre' do
      res = apptest.entete_check_and_display
      expect(res).to be_a(String)
      expect(res).to include 'CHECK DES FEATESTS' 
    end
  end



  describe '#config_file_valide?' do
    it 'répond' do
      expect(apptest).to respond_to :config_file_valide?
    end

    context 'avec un fichier de configuration valide' do
      before :all do
        build_app_test
      end
      it 'le site est considéré conforme' do
        expect(apptest).to be_config_file_valide
      end
    end
    
    context 'avec un dossier invalide' do
      context 'avec une application sans dossier ./spec conforme' do
        before :all do
          remove_app_test
          `mkdir -p "#{@app_path}"`
          expect(File.exist?(@app_path)).to be true
          CLI.param(file_path: @app_path)
        end
        it 'retourne false si le dossier ./spec n’existe pas' do
          expect(apptest).not_to be_config_file_valide
        end
        it 'retourne false si le dossier ./spec/features/apptest/' do
          `mkdir -p "#{File.join(@app_path, 'spec')}"`
          expect(apptest).not_to be_config_file_valide
        end
        it 'retourne false si le dossier ./spec/features/apptest/sheets et autres n’existent pas' do
          `mkdir -p "#{File.join(@app_path, 'spec','features','apptest')}"` 
          expect(apptest).not_to be_config_file_valide
        end
        it 'retourne false si le dossier ./spec/apptest/steps et autres n’existent pas' do
          `mkdir -p "#{File.join(@app_path, 'spec','features','apptest', 'sheets')}"` 
          `mkdir -p "#{File.join(@app_path, 'spec','features','apptest', 'steps')}"` 
          expect(apptest).not_to be_config_file_valide
        end
      end
    end
    
  end
end
