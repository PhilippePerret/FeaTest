# encoding: utf-8
module FeaTestModule

  # Retourne le dossier principal de test
  # Soit il est défini comme premier argument, soit on prend la
  # valeur étendue de '.'
  def main_folder
    @main_folder ||= File.expand_path(CLI.param(:file_path) || '.')
  end

  def steps_folder
    @steps_folder ||= File.join(featest_folder, 'steps')
  end
  def sheets_folder
    @sheets_folder ||= File.join(featest_folder,'sheets')
  end

  def featest_folder
    @featest_folder ||= File.join(main_folder,'spec','features','featest')
  end


end #/module
