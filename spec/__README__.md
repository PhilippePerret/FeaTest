# Test de Featest

Ces tests visent à tester le fonctionnement correct des FeaTests. Ils sont effectués avec `RSpec`.

## Application-test

Tous les essais se font avec l'application-test qu'on obtient par `apptest` défini dans le spec_helper. Par exemple :

    it "répond à config_valide?" do
      expect(apptest).to respond_to? :config_valide?
    end

Cette application se trouve dans le dossier `~/Sites/tests/appfeat`. On peut la gérer, la modifier pour le besoin des tests à l'aide des méthodes du dossier `./spec/support/required/app_test`.


## Messages

FeaTest étant une « application Terminal », elle utilise la méthode `puts`, en ruby, pour envoyer des messages de retour à l'user. Dans ces tests, ces messages sont captés et enregistrés dans :

```
{Array} FTMessage.messages
```

Pour forcer l'écriture d'un message depuis les tests avec la méthode `puts`, on ajoute un second argument à true :

    puts "le message", true

Cela forcera l'écriture du message avec la méthode normale.

## Application test

On utilise une application-test pour tester FeaTest. Cette application et ses réglages se trouvent dans le dossier `./spec/support/required/app_test/`.
