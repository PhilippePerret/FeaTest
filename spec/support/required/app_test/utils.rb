=begin

  Méthodes utiles pour l'application-test
  Cf. les constantes pour savoir où elle sera construite.

  build_app_test

    Construit la base d'une application test, en repartant de zéro.

  remove_app_test

    Détruit entièrement l'application test.
    Note : inutile de le faire avant de construire l'application puis-
    qu'elle sera automatiquement détruite.

=end


# Méthode qui construit la base minimum du test
def build_app_test
  atest = AppFeaTest.new
  atest.remove
  atest.build
end


def remove_app_test
  AppFeaTest.new().remove
end

