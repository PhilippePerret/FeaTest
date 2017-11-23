# encoding: utf-8
=begin

   Module qui définit toutes les données et les états utiles pour les tests,
   par exemple les étapes à jouer, les utilisateurs à considérer, etc.

=end
module FeaTestModule

  # Liste des étapes (Symbols) qui devront être jouées
  attr_reader :steps
  

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
