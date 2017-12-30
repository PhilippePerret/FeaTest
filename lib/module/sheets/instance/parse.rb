# encoding: utf-8
module FeaTestModule
  class FeaTestSheet

    # Contiendra tous les users-types de la feuille courante
    attr_reader :per_user_types

    # Méthode principale qui parle une feuille FeaTest pour en tirer les 
    # données de test.
    def parse
      @per_user_types = Hash.new

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
          when '-' then @per_user_types[current_utype].merge!(can_not_act_as_next: true)
          when '+' then @per_user_types[current_utype].merge!(can_act_as_previous: true)
          end
        when /^as: ?(.*?)(?:---(.*))?$/i
          # Définition d'un nouvel utilisateur
          utype = ($1||'').strip.downcase.to_sym
          desc  = ($2||'').strip
          @per_user_types.key?(utype) || @per_user_types.merge!(
            utype => {description: desc,   type: utype, 
                      features: Array.new, features_out: Array.new,
                      features_only: Array.new,
                      previous_user: current_utype, next_user: nil}
          )
          current_utype && @per_user_types[current_utype].merge!(next_user: utype)
          current_utype = utype
        when /^\* (.*?)(?:---(.*))?$/
          @per_user_types[current_utype][:features] << {
            hname: $1.nil_if_empty, affixe: $2.nil_if_empty, group: current_features_group
          }
        when /^\(\*\) (.*?)(?:---(.*))?$/
          # Fonctionnalité uniquement pour ce niveau
          @per_user_types[current_utype][:features_only] << {
            hname: $1.nil_if_empty, affixe: $2.nil_if_empty, group: current_features_group
          }
        when /^\-\* (.*?)(?:---(.*))?$/
          @per_user_types[current_utype][:features_out] << {hname: $1.nil_if_empty, affixe: $2.nil_if_empty}
        when /^\*\*\* (.*)$/
          current_features_group = $1.strip
        when /^STEP:(.*?)(?:---(.*))?$/i
          @step        = $1.nil_if_empty
          @description = $2.nil_if_empty
        else
          error "La ligne '#{line}' n'a pas été traitée."
        end
      end
      self.class.users_types.merge!(per_user_types)
    end
    #/parse
  end #/FeaTestSheet

end #/FeaTestModule
