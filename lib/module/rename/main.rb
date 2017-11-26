# encoding: utf-8
module FeaTestModule

  def rename feat_name = nil, new_name = nil, relpath = nil

    # On s'assure d'avoir toutes les données nécessaires
    retour = ask_for_each_param(feat_name, new_name, relpath) || return
    feat_name, new_name, relpath = retour

    step = find_step_in_relpath relpath
    folder = File.join(steps_folder,step)

    can_file  = search_can_file_in(feat_name, folder)
    can_file && notice("CAN FILE found in `#{can_file}`")
    new_can_file = can_file ? File.join(File.dirname(can_file),"can_#{new_name}.rb") : nil
    cant_file = search_cant_file_in(feat_name, folder)
    cant_file && notice("CAN'T FILE found in `#{cant_file}`")
    new_cant_file = cant_file ? File.join(File.dirname(cant_file),"CANT_#{new_name}.rb") : nil
    #can_file || cant_file || raise("No feature file exists. I can't operate…")
    can_file.nil?   || !File.exist?(new_can_file)   || raise("FILE CAN ALREADY EXISTS… (#{new_can_file})")
    cant_file.nil?  || !File.exist?(new_cant_file)  || raise("CAN'T FILE ALREADY EXISTS… (#{new_cant_file})")

    puts "\n\n"
    puts "*"*90
    puts "**** WILL RENAME : #{feat_name} -> #{new_name}"
    puts "     IN FTEST SHEET : #{folder.inspect}"
    mess =
    if can_file
      <<-EOT
      WILL MODIFY CAN FILE  : `#{relative_path can_file}`
                      INTO  : `#{relative_path new_can_file}`
      EOT
    else
      "     - no can file to modify -"
    end
    puts mess
    mess =
    if cant_file
      <<-EOT
      WILL MODIFY CANT FILE : `#{relative_path cant_file}`
                       INTO : `#{relative_path new_cant_file}`
      EOT
    else
      "     - no can't file to modify -"
    end
    puts mess 
    puts "*"*90 + "\n"
    if yesOrNo("Do I operate?")
      proceed_rename({
        step: step, folder: folder,
        feat_name: feat_name, new_name: new_name,
        can_file: can_file, cant_file: cant_file,
        new_can_file: new_can_file, new_cant_file: new_cant_file
      })
    end

  end
  #/rename

  def find_step_in_relpath relpath
    if relpath.match(/spec\/features\/featest/)
      File.expand_path(relpath).sub(/^#{sheets_folder}\//,'')
    else
      relpath
    end.sub(/\.ftest$/,'')
  end

  def ask_for_each_param feat_name, new_name, relpath
    begin
      feat_name ||= askForOrRaise("Feature name:")
      feat_name = feat_name.sub(/^(can|CANT)_/,'')

      # Si relpath est nil, il faut chercher dans quel .ftest est définie
      # la fonctionnalité. Si on ne la trouve pas, on affiche un message 
      # d'erreur et on s'en retourne.
      relpath ||= search_feature_relpath(feat_name) || (return nil)

      new_name ||= askForOrRaise("New name for feature:")
      feat_name != new_name || raise("Same names…")

      return [feat_name, new_name, relpath]
    rescue Exception => e
      error e.message
      puts e.backtrace.join("\n")
      return nil
    end
    
  end
  def proceed_rename params 

    # Renommer le can file s'il existe
    can_file  = params[:can_file]
    if can_file
      `mv "#{can_file}" "#{params[:new_can_file]}"`
      notice "= CAN File renamed"
    end

    # Renommer le CANT File s'il existe
    cant_file = params[:cant_file]
    if cant_file
        `mv "#{cant_file}" "#{params[:new_cant_file]}"`
        notice "= CANT File renamed"
    end

    # Dans le fichier des fonctionnalités
    ftest = File.join(sheets_folder,"#{params[:step]}.ftest")
    code  = File.read(ftest).force_encoding('utf-8')
    code.sub!(/--- ?#{params[:feat_name]}\b/, "--- #{params[:new_name]}")
    File.unlink(ftest)
    File.open(ftest,'wb'){|f|f.write code}
    notice "= Feature renamed in #{relative_path ftest}"
    puts "==================== RENAMING OK ==================="
  end
  
  def search_can_file_in feat_name, folder
    fname = "can_#{feat_name}.rb" 
    Dir.glob("#{folder}/**/#{fname}").first
  end
  def search_cant_file_in feat_name, folder
    fname = "CANT_#{feat_name}.rb"
    Dir.glob("#{folder}/**/#{fname}").first
  end

  def search_feature_relpath feat_name
    Dir["#{sheets_folder}/**/*.ftest"].each do |ftest|
      code = File.read(ftest).force_encoding('utf-8')
      if code.match(/--- ?#{feat_name}\b/)
        notice "Fonctionnalité `#{feat_name}` trouvée dans `#{relative_path ftest}`"
        return relative_path(ftest)
      end
    end
    raise "Impossible de trouver la fonctionnalité `#{feat_name}`"
  rescue Exception => e
    error e
  end
end #/FeaTestModule
