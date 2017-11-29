# encoding: utf-8
module FeaTestModule
  def steps
    @steps ||=
      begin
        etapes   = steps_sequence.select{|step| FeaTestSheet::ETAPES.key?(step)}
        # On prend les étapes choisies soit de l'option `steps` soit de 
        # l'option `step`
        opts_steps = CLI.option(:steps) || CLI.option(:step)
        lessteps =
          case opts_steps
          when 'all', NilClass
            # Toutes les étapes
            # TODO : ne faudrait-il pas prendre `etapes` ici, plutôt ?
            steps_sequence
          when /^(.*)-(.*)$/ 
            # Un rang d'étapes
            fr_step = $1.to_sym
            to_step = $2.to_sym
            etapes[etapes.index(fr_step)..etapes.index(to_step)]
          when /^.*,.*/
            opts_steps.split(',').collect{|e|e.to_sym}
          else
            # --steps avec une étape unique
            [CLI.option(:steps).to_sym]
          end
        lessteps
      end
  end
end #/FeaTestModule
