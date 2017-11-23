# encoding: utf-8
module FeaTestModule
  class Help
    class << self

      def display
        puts "Pour ouvrir le manpage, rejoindre le dossier et taper `man ./man`"
        puts "cd #{THISFOLDER}"
        puts "man ./man"
      end


    end #/<< self
  end#/Help
end #/FeaTestModule
