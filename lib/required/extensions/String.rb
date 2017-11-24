# encoding: utf-8

class String
  # Pour upcaser vraiment tous les caractères, même les accents et
  # les diacritiques
  FTEST_DATA_MIN_TO_MAJ = {
    from: "àäéèêëïùôöç",
    to:   "ÀÄÉÈÊËÎÏÙÔÖÇ"
  }

  def titleize
    t = self.full_downcase
    t[0] = t[0].full_upcase
    return t
  end

  def full_upcase
    self.upcase.tr(FTEST_DATA_MIN_TO_MAJ[:from], FTEST_DATA_MIN_TO_MAJ[:to])
  end

  def full_downcase
    self.downcase.tr(FTEST_DATA_MIN_TO_MAJ[:to], FTEST_DATA_MIN_TO_MAJ[:from])
  end

end #/String
