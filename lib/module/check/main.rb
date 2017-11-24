# encoding: utf-8
module FeaTestModule

  def check_and_display
    require_module 'validation'
    featest_valide?(check: true) || 
      begin
        puts "Poursuite du check impossible si tous les dossiers ne sont pas présents."
        return
    end

    require_module 'sheets'
    FeaTestSheet.analyze_sheets(sheets_folder)

    check_etapes
  end

  # On teste toutes les étapes
  def check_etapes
    FeaTestSheet::ETAPES.each do |ketape, etape|
      etape.check
    end
  end

end #/FeaTestModule
