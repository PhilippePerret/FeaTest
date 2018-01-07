=begin

  Test de la méthode qui crée les fichiers de test par user
  demandé.

=end

# Test de la méthode qui crée le dossier qui va contenir
# tous les fichiers construits de test par type de user.
describe 'Featest#build_folder_test_files_per_user' do
  before(:all) do
    require_module 'test'
  end
  it 'répond' do
    expect(apptest).to respond_to :build_folder_test_files_per_user
  end
  it 'reconstruit le dossier contenant les feuilles de test par type de user' do
    d = apptest.steps_by_users_folder
    FileUtils.rm_rf(d) if File.exist?(d)
    expect(File.exist?(d)).to eq false
    # ==========> TEST <==============
    apptest.build_folder_test_files_per_user
    # =========== VÉRIFICATION ============
    expect(File.exist?(d)).to eq true
  end
end
describe 'Featest#define_sheets_steps' do
  before(:all) do
    require_module 'test'
    require_module 'sheets'
  end
  it 'répond' do
    expect(apptest).to respond_to :define_sheets_steps
  end
  it 'définit les « sheets steps » dans FeaTestSheet' do
    FeaTestModule::FeaTestSheet.sheets_steps = nil
    expect(FeaTestModule::FeaTestSheet.sheets_steps).to eq({})
    apptest.define_sheets_steps
    expect(FeaTestModule::FeaTestSheet.sheets_steps).not_to eq({})
  end
end
describe 'Featest#create_test_file_for_user' do
  before(:all) do
    require_module 'test'
    require_module 'sheets'
  end
  it 'répond' do
    expect(apptest).to respond_to :create_test_file_for_user
  end
  it 'crée le fichier voulu' do
    user_type = :visitor
    fpath = File.join(apptest.steps_by_users_folder, "#{user_type}_spec.rb")
    File.unlink(fpath) if File.exist?(fpath)
    # log "fpath: #{fpath}"
    # ========== PRÉPARATION ==========
    # Au cas où… on procède à la préparation de la construction des
    # feuille de test.
    # On construit le dossier qui va contenir chaque feuille de test par
    # type d'utilisateur
    apptest.build_folder_test_files_per_user
    # On définit les fichiers steps
    apptest.define_sheets_steps
    # On requiert le fichier config qui est requis avant dans la procédure
    # complète
    require apptest.config_file_path
    # On définit la donnée `user_types` de FeaTestSheet pour que l'application
    # connaisse les utilisateurs pour qui on doit créer une feuille de test
    FeaTestModule::FeaTestSheet.users_types= {visitor: {pseudo: 'Simple visiteur', mail: 'visitor@chez.lui', password:'xxxxxxxx'}}

    # =========> TEST <===========
    apptest.create_test_file_for_user(user_type)

    # =========== VÉRIFICATIONS ============
    expect(File.exist?(fpath)).to eq true

    log File.read(fpath)

  end
end
