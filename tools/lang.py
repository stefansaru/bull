"""Deterministic lightweight language guesser for EN / RO / FR / DE.

Scores by (a) language-specific diacritics and (b) common stopwords.
Good enough to distinguish the four languages of this book; deterministic
(no model downloads). Returns one of 'en','ro','fr','de','?'.
"""
import re

DIACRITICS = {
    "ro": "ăâîșțşţĂÂÎȘȚŞŢ",
    "fr": "àâçéèêëîïôùûüÿœ",
    "de": "äöüßÄÖÜ",
}
STOP = {
    "en": " the and is are this that for with which their they were was from have has not but ".split(),
    "ro": " și şi este sunt care pentru această acest după când mai fără dintre timbre au fost din nu ".split(),
    "fr": " le la les des une est sont qui pour dans cette être avec plus sans timbres ont été au aux du ".split(),
    "de": " der die das und ist sind für eine den mit auf wurde wurden von nicht auch als briefmarken ".split(),
}


def guess(text):
    if not text or not text.strip():
        return "?"
    t = text.lower()
    words = re.findall(r"[a-zàâçéèêëîïôùûüÿœäöüßăâîșțşţ]+", t)
    if not words:
        return "?"
    n = len(words)
    score = {k: 0.0 for k in ("en", "ro", "fr", "de")}
    # diacritic signal (strong)
    for lang, chars in DIACRITICS.items():
        c = sum(text.count(ch) for ch in chars)
        score[lang] += 3.0 * c
    # stopword signal
    padded = " " + " ".join(words) + " "
    for lang, sw in STOP.items():
        for w in sw:
            score[lang] += padded.count(" " + w.strip() + " ")
    # French apostrophe elisions
    score["fr"] += 1.5 * len(re.findall(r"\b[ldjcnst]['’]", t))
    # German capitalised-noun tendency (weak)
    caps = len(re.findall(r"\b[A-ZÄÖÜ][a-zäöüß]{2,}", text))
    score["de"] += 0.15 * caps
    # normalise English as fallback baseline
    score["en"] += 0.5
    best = max(score, key=score.get)
    return best


if __name__ == "__main__":
    import sys, io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8")
    for s in ["The first Romanian stamps", "Primele timbre poștale românești",
              "Les premiers timbres roumains", "Die ersten rumänischen Briefmarken"]:
        print(guess(s), "|", s)
