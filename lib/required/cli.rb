# encoding: utf-8
class CLI
  # Définit les options courtes (-) vers les longues (--)
  SHORT_OPT_TO_FULL = {
    'r'   => :random,
    'dg'  => :debug
  }
  # Définit l'ordre des paramètres.
  # Permet ensuite de faire `CLI.param(<key>)` pour obtenir la valeur
  # d'un paramètre.
  PARAMS_ORDER = {
    file_path: 0
  }

  # --------------------------------------------------------------------------------
  #
  #    Tout ce qu'il y a en dessous peut être commun à n'importe quel
  #    interface de ligne de commande.
  # 
  # --------------------------------------------------------------------------------
  ARGS = {
    options: Hash.new,
    params:  Array.new
  }
  class << self

    # Retourne la valeur de l'option +key+
    # @usage    CLI.option(<key>)
    def option key
      ARGS[:options][key]
    end

    # Retourne la valeur du paramètre de clé +key+
    # @usage    CLI.param(<key>)
    #
    # +key+ doit être défini dans PARAMS_ORDER ci-dessus
    # OU être l'index 1-start des paramètres
    def param key
      case key
      when Fixnum then ARGS[:params][key - 1]
      else
        ARGS[:params][PARAMS_ORDER[key]]
      end
    end

    def parse
      ARGV.each do |a|
        case a
        when /^--(.*)$/
          full_opt, value = get_prop_value(a[2..-1])
          ARGS.merge!(full_opt.to_sym => value)
        when /^-(.*)$/
          short_opt, value = get_prop_value(a[1..-1])
          full_opt = SHORT_OPT_TO_FULL[short_opt]
          ARGS.merge!(full_opt => value)
        else
          # un argument
          ARGS[:params] << a
        end
      end
    end
    #/parse
    #

    def get_prop_value paire
      if paire.match(/=/) 
        prop, val = paire.split('=')
        val = val.gsub(/^["']?(.*)["']?$/)
        [prop, val]
      else
        [paire, true]
      end
    end
  end #/<< self
end #/CLI
