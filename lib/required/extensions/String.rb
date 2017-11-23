# encoding: utf-8
class String
  def titleize
    t = self.full_downcase
    t[0] = t[0].full_upcase
    return t
  end

  # Pour upcaser vraiment tous les caractères, même les accents et
  # les diacritiques
  DATA_MIN_TO_MAJ = {
    from: "àäéèêëïùôöç",
    to:   "ÀÄÉÈÊËÎÏÙÔÖÇ"
  }
  def full_upcase
    self.upcase.tr(DATA_MIN_TO_MAJ[:from], DATA_MIN_TO_MAJ[:to])
  end

  def full_downcase
    self.downcase.tr(DATA_MIN_TO_MAJ[:to], DATA_MIN_TO_MAJ[:from])
  end

end #/String
