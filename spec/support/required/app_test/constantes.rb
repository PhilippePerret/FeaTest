=begin

  Constantes utiles pour l'application-test
  À commencer par APP_TEST_PATH, le chemin d'accès absolu à cette app-
  test.

=end

# Chemin d'accès à la racine de l'application test
# Note : si on modifie ce chemin, il faut également modifier l'url offline
# dans le fichier support/required/app_test/app_test_instance.rb
APP_TEST_PATH = File.expand_path(File.join(Dir.home,'Sites','tests', 'appfeat'))

# Chemin d'accès absolu au dossier contenant les featests de l'app-test
APP_FEATEST_FOLDER = File.join(APP_TEST_PATH,'spec','features','featest')

# Chemin d'accès absolu au dossier ./lib de l'application-test
APP_TEST_LIB = File.join(APP_TEST_PATH,'lib')
