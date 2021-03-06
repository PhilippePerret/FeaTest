# MANUEL DE FEATEST (FDD)

## CONFIGURATION GÉNÉRALE

Pour pouvoir fonctionner, les featests ont besoin de cette hiérarchie

    app-folder/spec/features/featest/sheets     -- dossier des définitions des
                                                   fonctionnalités.
                                     steps      -- codes des tests proprement dits.
                                     config.rb  -- définitions générales obligatoires

## FICHIER CONFIG.RB

Le fichier `config.rb`, à la racine du dossier featest, doit étendre le module `FeaTestModule` pour définir des valeurs obligatoires, à savoir :

    - les URLS online et offline              url_online, url_offline
    - la liste des étapes, dans l'ordre       steps_sequence
    - les données d'identification pour       data_user(<user type>)
      tous les types d'users définis, avec
      le bon niveau. C'est une méthode qui
      doit retourner le code à écrire pour
      obtenir le Hash des données de l'user en fonction de son type.

Ce fichier doit donc contenir le code :

      module FeaTestModule
        def url_online
          @url_online ||= ...
        end
        def url_offline
          @url_offline ||= ...
        end
        def steps_sequence
          @steps_sequence ||= [
            ...
          ]
        end
        def data_user utype
          case utype
          when ... then <<~EOC
          huser = "{pseudo: ..., id:..., password:..., mail:...}"
          when ...
          end
        end
      end #/module

## PREMIÈRES FEUILLES DE TEST .FTEST

Feuilles obligatoires :

    - home.ftest        Définition de la page d'accueil
    - signin.ftest      Mode d'identification

La première feuille de test à créer, obligatoire, est celle qui définit l'accueil du site, donc ce qu'on s'attend à trouver, par utilisateur, sur la page d'accueil.

Il peut s'agir seulement du logo.

Cette feuille se définit dans :

      <app>/spec/features/featest/sheets/home.ftest

Elle est au format normal des featest-sheets (feuille featest). Cf. FORMAT DES FICHIERS .fest plus bas.

La feuille signin.ftest se définit elle dans :

      <app>/spec/features/featest/sheets/signin.ftest

On peut ensuite jouer la commande :

      cd <app folder>
      featest build

… pour construire les fichiers qui vont permettre de définir les codes des tests.

On implémente dans ces fichiers les codes des tests.

On peut ensuite jouer la commande :

      > featest [options]

… pour lancer les premiers tests.


## PROCÉDURE POUR CRÉER DES FEAT TESTS

### Procédure générale

1- Définition des fonctionnalités par `step` dans le dossier featest/steps/
2- Demande de construction des steps (optionnel)
3- Définition du code de test de chaque fonctionnalité et contre-fonctionnalité
4- Lancement du test avec choix des étapes à jouer, des utilisateurs


### Procédure détaillée

#### 1- Définition des fonctionnalités par `step`

Une `step` peut être compris comme une `section` du site. C'est par exemple la section Forum d'un site.

Pour définir les tests de cette section, on crée son fichier :

      `featest/steps/<step>.ftest`

Par exemple, pour le forum :

      `featest/steps/forum.ftest`

C'est à l'intérieur de ce fichier que vont être définies et décrites sommairement toutes les fonctionnalité de l'étape (p.e. du forum). Voir plus "Format des fichiers .ftest."

#### 2- Demande de construction des steps (optionnel)

Plutôt que de créer les fichiers qui vont contenir le code de test "à la main", on peut lancer la commande `featest build` (à la racine du site) qui va construire tous les fichiers fonctionnalités qu'il ne trouve pas. C'est le plus sûr moyen de travailler avec des noms valides. la commande `featest check` permet quant à elle de s'assurer qu'on a tous les éléments valides.

#### 3- Définition du code de test de chaque fonctionnalité

Dans chaque fichier de code de fonctionnalité créé par l'étape précédente, on peut définir le test à opérer.

On peut se servir ici de toutes les méthodes pratiques qui ont été créées dans les supports de test.

#### 4- Lancement des tests.

Il suffit ensuite d'utiliser la commande `featest`, avec les options voulues, pour lancer les tests.

Par exemple, `featest --as=inscrit --fail-fast` lancera un test seulement sur l'user de type `inscrit` et s'arrêtera à la première erreur.


## FORMAT DES FICHIERS .ftest

  TODO

## CONSTRUIRE LES TESTS

Après avoir défini les fonctionnalités dans les fichiers `.ftest` et avoir construit les fichiers correspondants avec la  commande `featest  build`, on peut s'atteler  à définir les tests proprement dits.

De nombreuses méthodes pratiques permettent de rendre le code du test plus clair, mais on peut faire simplement du pure `RSPEC` dans les fichiers `.ftest`.

### Forcer un nouveau scénario

Parfois, il est utile de repartir d'un nouveau scénario pour repartir d'un utilistateur tout à fait vierge, sans sessions, etc. Pour ce faire, il suffit d'utiliser la balise `NEW_SCENARIO` à l'endroit où doit commencer le nouveau scénario. Toutes les données utiles seront également inscrites à cet endroit.

### Méthodes pratiques

En plus des méthodes de support définies pour le site, on peut trouver certaines méthodes utiles directement implémentées. En voici la liste complète :

      visit_home_page

Pour faire que l'user courant revisite le site dans une nouvelle session. Permet de repartir "à zéro", avec un visiteur sans session, donc non identifié, etc.

## REJOUER LES TESTS

Noter qu'après avoir lancé une première fois `featest` avec les paramètres voulus, on peut lancer les feuilles de test produites avec rspec, tout simplement.

Ces feuilles de test se trouvent définies dans le dossier `.steps_by_users` du dossier `featest` de l'application testée.

On peut bien sûr modifier ces fichiers directement pour ajuster certains tests, mais il est important de comprendre qu'au prochain lancement de `featest`, ces modifications seront écrasées et remplacées par les définitionsdes steps. Moralité, si l'on souhaite conserver une modification, il faut la reporter dans le fichier du dossier `steps` correspondant.


## RENOMMER UNE FONCTIONNALITÉ/FEATURE

Il arrive fréquemment qu'on veuille renommer une fonctionnalité. Cela consiste à trois opération distinctes :

* renommer le fichier `can_`
* renommer le fichier `CANT_`
* modifier le fichier `.ftest` qui la contient.

Plutôt que de prendre le risque de placer un mauvais nom, on peut utiliser la commande :

      featest rename ...

… qui permet d'exécuter les trois opérations d'un coup et sans erreur.

Cette commande prend trois arguments, le nom (sans `can`) de la fonctionnalité, le nouveau nom à lui attribuer et, exceptionnellement, s'il peut y avoir ambiguïté, le path relatif du dossier de cette fonctionnalité dans le dossier `./spec/features/festest`

Par exemple :

      featest rename ma_fonctionnalite mon_nouveau_nom home

La commande ci-dessous remplacera le nombre `ma_fonctionnalite` par `mon_nouveau_nom` dans les deux fichiers can et CANT (if any) ainsi que dans le fichier `home.test` qui la contient.

Noter que la commande est interactive, donc on peut simplement taper :

      > featest rename

… et l'application nous accompagne dans la suite.

## ANCIEN MANUEL
  =============

TODO Reporter les options ci-dessous dans le manuel.

ALIAS BASH  :

              [ --from=<etape>]
              [ --to=<etape>]
              [ --wait=<coefficiant attente>]
              [ --quiet/--silent]


Pour lancer la version intégrale et complète des tests :

        $> test_spole --as=all --exhaustif

        (attention : ça peut prendre la nuit, car ça teste le site de façon
         exhaustive, avec chacun des utilisateurs possibles l'un après l'autre)


    --exhaustif

      Si cette option est présente, c'est un test EXHAUSTIF qui est produit.
      Un exemple valant mieux que de longs discours… par exemple, pour le test
      des livres de la collection, si on est en mode exhaustif, on teste TOUS
      les livres, alors qu'en mode non exhautif, on ne traite que trois livres
      grâce à cette condition :

          book_ids = <select tous les livres.exhaust

      On peut envoyer à la méthode `Array#exhaust` le nombre d'éléments par
      défaut en cas de non exhaustivité (mode "non exhaustif").

    --non-exhaustif

      Correspond à l'absence de l'option `--exhaustif`, pour la clarté, on peut
      bien le préciser de cette manière.

    --grade=<0-9>

      Définit le grade que doit avoir l'utilisateur.
      Fonctionne pour tous les users hormis administrateur et simple visiteur.

    --wait=<coefficiant d'attente>

      Permet de définir le coefficiant d'attent, qui a pour valeur par défaut
      1.
      Si le nombre est supérieur à 1, l'attente sera allongée entre les
      pause (il y a de nombreuses pauses pour pouvoir suivre l'affichage des
      page).
      Si le nombre est entre 0 et 1, l'attente sera raccourcie.
      Si le nombre est 0, toute attente est supprimée.

    --silent / --quiet

      En temps normal, dans les tests, on peut utiliser la méthode `say` pour
      annoncer ce que l'utilisateur va faire. On peut désactiver cette
      fonctionnalité (qui consomme du temps) en utilisant une de ces deux
      options.
      Noter que l'option générale --fast

    --fast

      Accélère les tests en supprimant le temps d'attente (--wait) et l'afficha-
      ge des messages "say" (qui annoncent les prochaines opérations).

    --[no-]fail-fast

      Comme pour RSPEC, si l'option existe, on s'arrête à la première erreur,
      sinon, si `nofail-fast`, on s'arrête en bout de test. Par défaut, on va
      au bout du test

      Noter cependant que cette option agit de façon particulière, puisque les
      tests de ce programme sont en fait un unique test. Donc, même avec l'op-
      tion `--no-fail-fast`, ils s'interromperaient dès la première erreur.
      Mais ici, le corps du code de test de chaque section est enroulé dans un
      rescue qui empêche d'arrêter le test à la première erreur. La contrepartie
      est que le message d'erreur, si `--debug` n'est pas activé, est réduit au
      simple message d'erreur, qui n'est pas toujours très éclairant.


------------------------------------------------------------------------------

## FICHIER init.rb

Le fichier ./spec/features/featest/init.rb permet d'initialiser les featests en fonction de l'application testée.

On peut définir l'ordre des étapes à jouer par :

          FeaTest.current.steps_sequence = [....]

En cas de non définition, l'ordre des étapes sera celui déterminé par la relève normale dans le dossier .../featest/sheets/

------------------------------------------------------------------------------

### LISTE ACTUELLE DES ÉTAPES

(note : cette liste est actualisée automatiquement)

      __ETAPES__
