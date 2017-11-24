# encoding: utf-8
module FeaTestModule

  class FeaTestSheet
    # Méthode principale qui parle une feuille FeaTest pour en tirer les 
    # données de test.
    def parse
      current_utype = nil
      current_features_group = nil
      File.open(path).readlines.each do |line|
        line = line.strip
        line.start_with?(':') && next # commentaire
        line.gsub(/[-=]/,'') != '' || next # soulignement
        #puts "line: #{line}"
        case line
        when /\* ([\-\+])/
          case $1
          when '-' then USER_TYPES[current_utype].merge!(can_not_act_as_next: true)
          when '+' then USER_TYPES[current_utype].merge!(can_act_as_previous: true)
          end
        when /^as: ?(.*?)(?:---(.*))?$/i
          # Définition d'un nouvel utilisateur
          utype = ($1||'').strip.downcase.to_sym
          desc  = ($2||'').strip
          USER_TYPES.key?(utype) || USER_TYPES.merge!(
            utype => {description: desc,   type: utype, 
                      features: Array.new, features_out: Array.new,
                      previous_user: current_utype, next_user: nil}
          )
          current_utype && USER_TYPES[current_utype].merge!(next_user: utype)
          current_utype = utype
        when /^\* (.*)---(.*)$/
          USER_TYPES[current_utype][:features] << {
            hname: $1.strip, affixe: $2.strip, group: current_features_group
          }
        when /^\-\* (.*)---(.*)$/
          USER_TYPES[current_utype][:features_out] << {hname: $1.strip, affixe: $2.strip}
        when /^\*\*\* (.*)$/
          current_features_group = $1.strip
        when /^STEP:(.*?)(---(.*))$/i
          @step             = $1.strip
          @step_description = $2.strip
        else
          error "La ligne '#{line}' n'a pas été traitée."
        end
      end
    end
  end

end #/FeaTestModule
