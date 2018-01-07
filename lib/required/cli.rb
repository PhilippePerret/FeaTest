# encoding: utf-8
class CLI

  defined?(ARGS) || ARGS = Hash.new # peut être défini par les tests

  # Définit les options courtes (-) vers les longues (--)
  SHORT_OPT_TO_FULL = {
    'a'   => :aide,
    'b'   => :build,
    'dg'  => :debug,
    'm'   => :man,
    'p'   => :path,
    'r'   => :random,
    't'   => :tuto,
    'w'   => :wait
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

  class << self

    # Retourne la valeur de l'option +key+
    # @usage    CLI.option(<key>)
    def option key
      ARGS[:options][key.to_sym]
    end

    # Retourne la valeur du paramètre de clé +key+
    # @usage    CLI.param(<key>)
    #
    # +key+ doit être défini dans PARAMS_ORDER ci-dessus
    # OU être l'index 1-start des paramètres
    def param key, value = '__none__'.to_sym
      ARGS.key?(:params) || reset_args
      case key
      when Hash
        key.each do |k, v|
          ARGS[:params][PARAMS_ORDER[k]] = v
        end
      else
        if value == '__none__'.to_sym
          case key
          when Fixnum
            ARGS[:params][key - 1]
          else
            ARGS[:params][PARAMS_ORDER[key]]
          end
        else
          ARGS[:params][PARAMS_ORDER[key]] = value
          value
        end
      end
    end

    # MÉTHODE PRINCIPALE qui parse la ligne de commande pour en tirer
    # toutes les informations.
    def parse
      reset_args
      ARGV.each do |a|
        case a
        when /^--(.*)$/
          full_opt, value = get_prop_value($1.strip)
          ARGS[:options].merge!(full_opt.to_sym => value)
        when /^-(.*)$/
          short_opt, value = get_prop_value($1.strip)
          full_opt = SHORT_OPT_TO_FULL[short_opt]
          ARGS[:options].merge!(full_opt => value)
        else
          # un argument
          ARGS[:params] << a
        end
      end
      rectif_options
      __dg("<- CLI.parse",2)
      __db("   with: ARGS = #{ARGS.inspect}",4)
    end
    #/parse

    # Retourne le niveau de débuggage, en fonction des options choi-
    # sies ou non pour le définir. Sert principalement aux messages.
    def debug_level
      ARGS[:options][:debug_level]
    end

    # Permet de rectifier certaines valeurs d'options de la
    # commande.
    def rectif_options
      opts = ARGS[:options]
      opts.delete(:debug) && opts.merge!(:'debug-level' => 5)
      opts[:debug_level] = (opts.delete(:'debug-level') || 0).to_i
      opts[:'non-exhaustif'] && opts.merge!(exhaustif: false)
      if opts[:fast]
        opts[:wait]   = 0
        opts[:silent] = true
      end
      opts[:wait] = opts[:wait].nil? ? 1 : opts[:wait].to_f
      opts[:fail_fast] = !!opts[:'fail-fast']
      ARGS[:options].merge!(opts)
    end


    def get_prop_value paire
      if paire.match(/=/)
        prop, val = paire.split('=')
        val.gsub!(/^["']?(.*)["']?$/,'\1')
        [prop, val]
      else
        [paire, true]
      end
    end

    # Ré-initialisation des valeurs (surtout utile pour les tests,
    # mais appelé au début du parse de la ligne de commande)
    def reset_args
      ARGS[:options] = Hash.new
      ARGS[:params]  = Array.new
    end
  end #/<< self
end #/CLI
