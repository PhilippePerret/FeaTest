# encoding: utf-8
module FeaTestModule

  # Première étape : préparation de la construction du 
  # test.
  # C'est ici qu'on prend toutes les options définies et
  # qu'on en tire les spécificités du test à mener.
  #
  def prepare
    FeaTestSheet.analyze_sheets(sheets_folder)
    define_steps
    require './spec/spec_helper'
  end

  def define_steps
    etapes = FeaTestSheet::ETAPES
    @steps =
      case CLI.option(:step)
      when NilClass
        case CLI.option(:steps)
        when 'all', NilClass
          # Toutes les étapes
          etapes.keys
        when /^(.*)-(.*)$/ 
          # Un rang d'étapes
          fr_step = $1.to_sym
          to_step = $2.to_sym
          etapes[etapes.index(fr_step)..etapes.index(to_step)]
        when /^.*,.*/
          CLI.option(:steps).split(',').collect{|e|e.to_sym}
        end
      else
        [CLI.option[:step].to_sym]
      end
    steps_valides_or_raise?
  end

  # Vérifie que les étapes existent belles et bien, c'est-à-dire qu'il y ait
  # un dossier dans le dossier des étapes portant le même nom
  def steps_valides_or_raise?
    steps.each do |step|
      p = File.join(steps_folder,step.to_s)
      File.existsOrRaise(p, "Le DOSSIER STEPS `#{step}` n'existe pas… (`%s`)")
    end
  end



end #/FeaTestModule
