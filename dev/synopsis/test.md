# Synopsis d'un test

Cette page décrit le synopsis de fonctionnement lorsqu'on lance `featest` sur un site.

## PRÉ-REQUIS

L'application ou le site web — ci-dessous nommés "l'app" — doit posséder un dossier `./spec/features/featest` qui contient la définition des tests.


## SYNOPSIS

Le programmeur joue la commande :

    > cd path/to/app/folder
    > featest .

… pour jouer l'intégralité des tests.

./featest.rb

      Une nouvelle instance de `Featest` est créée
      et on appelle sa méthode `run`

./lib/required/FeaTest/instance/run.rb

      #run
      La méthode `run` commence par demander le parse de la ligne
      de commande (CLI.parse). Voir le synopsis de cette méthode.

      Puis appelle la méthode `#prepare_build_and_run_test` de l'instance

.idem

      #prepare_build_and_run_test
      * Vérifie que les données sont OK pour les tests (#data_ok_for_test?)
        Si les données ne sont pas bonnes, on s'en retourne
        Sinon, poursuit.

      * requiert le module 'test'
      * appelle la méthode #build_and_run_tests de ce module.

./lib/module/test/main.rb

      #build_and_run_tests
        va construire un fichier par utilisateur pour les tests et les jouer.
      * requiert le module 'validation'
      * vérifie si les featests sont valides (#featest_valide?)
        Si non valide, s'en retourne avec la valeur false.
        Sinon, poursuit.
      * Se place dans le dossier de l'application
      * prepare les tests     #prepare
            Vérifie que les fichiers de test (test sheet) existent et
            prépare les utilisateurs qui vont être testés (:as) avec la
            méthode `#define_users` qui définit la pseudo-constante `AS` qui
            contient les users "symboliques" (:visitor, etc.)
      * construit les tests   #build_test
          La méthode `#build_test` construit chaque feuille de test pour un
          user de niveau déterminé (simplement visiteur, inscrit, admin, etc.)
      * joue les tests        #run_test
      * retourne true

### Détail des procédures ci-dessus

./lib/module/test/prepare.rb

      #prepare

./lib/module/test/build/build_test.rb

      #build_test
      * détruit et reconstruit le dossier qui va contenir chaque feuille
        de test.
      * appelle la méthode `#create_test_file_for_user` sur chaque user
        de `AS` pour construire sa feuille de test.


      #create_test_file_for_user
      Méthode qui crée le fichier de test pour un user donné (:visitor, etc.)

      Construit le fichier de test en mettant en code :

      * le résultat de #preambule_test_file
      * la méthode `require_folder`
      * requiert les fichiers de `./lib/asset/spec_helpers`
