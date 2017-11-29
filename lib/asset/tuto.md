# Tutoriel pour FeaTest


...

[Ici, j'ai préparé `signin.ftest`, `forum.ftest` et `home.ftest`]


Après avoir préparé toutes mes "featest sheets" (mes <em>feuilles de featest</em>), je peux lancer la commande qui va vérifier les fichiers manquants.

Je vais utiliser la commande :

    > featest check

Mais comme je veux me limiter pour le moment à la procédure d'identification et à la page d'accueil, j'utilise l'option `--steps` avec le nom des étapes.

    > featest check --steps=home,signin


En lançant cette commande, j'affiche les résultats de ce test, qui m'indique les fichiers manquants.

Je peux à présent ajouter l'option `--build` (ou `-b`) pour construire ces fichiers manquants.

    > featest check --steps=home,signin -b

J'aurais pu aussi utiliser :

    OU > featest build --steps=home,signin

Les deux commandes sont équivalentes, une seule doit être jouée ici.
