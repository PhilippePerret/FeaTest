# encoding: utf-8
module FeaTestModule

  # Première étape : préparation de la construction du
  # test.
  # C'est ici qu'on prend toutes les options définies et
  # qu'on en tire les spécificités du test à mener.
  #
  def prepare
    __dg("-> prepare",1)

    define_sheets_steps

    require 'rspec'
    require './spec/spec_helper'
    # Si un fichier config.rb existe, on le joue
    File.exist?(config_file_path) || raise("Le fichier config.rb doit absolument exister.")
    require config_file_path
    # provoque la définition de `steps`, les étapes à jouer
    steps_valides_or_raise?
    define_users
    __dg("<- prepare",1)
  end

  def define_sheets_steps
    require_module 'sheets'
    FeaTestSheet.analyze_sheets(sheets_folder)
  end

  def define_users
    __dg("-> define_users",2)
    # Le ou les types de user à traiter
    as = CLI.option(:as)
    __dg("   --as=#{as.inspect}",4)
    if as.nil?
      AS << :visitor
    elsif as.match(/,/)
      as.split(',').each{|utype| AS << utype.strip.to_sym}
    elsif as == 'all'
      FeaTestSheet.users_types.keys.each{|ut| AS << ut}
    else
      AS << as.to_sym
    end
    __dg("<- define_users",2)
    __dg("   (AS = #{AS.inspect})")
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
