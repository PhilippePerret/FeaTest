# encoding: utf-8
=begin

   Module qui définit toutes les données et les états utiles pour les tests,
   par exemple les étapes à jouer, les utilisateurs à considérer, etc.

=end
module FeaTestModule

  # Liste des types de user qu'il faut traiter au cours du test courant
  #
  # Attention, ne pas confondre cette liste, qui dépend de la ligne de
  # commande lançant le test, avec la pseudo-constante FeaTestSheet::USER_TYPES
  # qui contient la liste des types d'user définis dans les feuilles de
  # FeaTest.
  AS = Array.new

  # Liste des étapes (Symbols) qui devront être jouées
  # Elle peut être définie par :
  #     FeaTest.steps_sequence = [...] dans le fichier
  #     ./spec/features/featest/init.rb
  # Si elle n'est pas définie, on prendra la liste de 
  # définition dans les feuilles de featest.
  attr_accessor :steps_sequence
  
  # Les étapes telles qu'elles se présentent dans les feuilles featest.
  attr_accessor :steps


  # Le visiteur qui visite, en version humaine, pour les textes
  def human_user utype
    FeaTestSheet::USER_TYPES[utype][:hname] || 'le visiteur quelconque'
  end

  # Pour savoir s'il faut jouer les tests online ou offline
  def offline?
    @is_offline ||= 
      begin
        unless CLI.option(:offline) === nil
          !!CLI.option(:offline)
        else
          !!CLI.option(:online)
        end
      end
  end
  def online? ; !offline? end

end #/FeaTestModule
