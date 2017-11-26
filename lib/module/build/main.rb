# encoding: utf-8
module FeaTestModule

  # Construit tous les fichiers manquants.
  def build_all_files

    require_module 'check'
    require_module 'sheets'

    FeaTestSheet.analyze_sheets(sheets_folder)
    FeaTestSheet::ETAPES.each do |ksteps,etape|
      etape.check(build: true)
    end
    
    puts "\n\n"
    notice "Tous les fichiers ont été créés avec succès."
    puts "\n\n"
  end

end #/FeaTestModule
