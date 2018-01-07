# encoding: utf-8

require 'fileutils'

THISFOLDER = File.dirname(File.dirname(__FILE__))

# Requérir tous les modules
Dir["#{THISFOLDER}/lib/required/**/*.rb"].each{|m|require m}
