#!/usr/bin/env ruby
# encoding: utf-8
=begin
  
  Fichier principal

=end

require_relative 'lib/required'

# On analyse les paramètres de la ligne de commande
FeaTest.get_parameters

# On joue le test
FeaTest.run

puts "C'est fini"
