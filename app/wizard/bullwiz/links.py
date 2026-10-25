"""Links inside the content bundle (UIC-LNK, UIC-ART-03, bull DR-015).

Text in the bundle carries links as `⟦artefact-id|label⟧`. Three sources feed them:

1. wikilinks written in the wiki, resolved to page ids while the text is cleaned;
2. `finalize`, which keeps only links whose target ships as an artefact (others
   fall back to their label);
3. `autolink`, a curated build-time pass: multi-letter abbreviations, colour names
   and codes, (J)/(G) markers, and dual dates — which it also rewrites into the
   DR-015 notation `1 (13) June 1865 ᴶ⁄ᴳ`. The wiki itself is never modified.
"""

from __future__ import annotations

import re
from collections import Counter
from contextvars import ContextVar
from dataclasses import dataclass, field
from datetime import date
from pathlib import Path
from typing import Any, Callable, Iterable

from . import paths

MARK = re.compile(r"⟦(?P<id>[^|⟧]+)\|(?P<label>[^⟧]*)⟧")

# Index artefacts the bundle generates itself; wiki README pages that stand for them.
INDEX_FOR_PAGE = {"entities/abbreviations/README": "index/abbreviations",
                  "entities/colors/README": "index/colours"}

JULIAN = "entities/concepts/julian-calendar"
GREGORIAN = "entities/concepts/gregorian-calendar"
DUAL_DATE = "entities/concepts/dual-date-notation"
DUAL_TAG = "ᴶ⁄ᴳ"

current_page: ContextVar[Path | None] = ContextVar("current_page", default=None)


def mark(target: str, label: str) -> str:
    return f"⟦{target}|{label}⟧"


def strip(text: str) -> str:
    """Plain text: links reduced to their labels (search, TTS, titles)."""
    return MARK.sub(lambda m: m.group("label"), text)


# --------------------------------------------------------------------------- resolution

class Resolver:
    """Obsidian-style wikilink resolution: relative, root-relative or bare unique stem."""

    def __init__(self, wiki: Path):
        self.wiki = wiki.resolve()
        self.pages: set[str] = set()
        stems: dict[str, list[str]] = {}
        for p in self.wiki.rglob("*.md"):
            pid = p.resolve().relative_to(self.wiki).with_suffix("").as_posix()
            self.pages.add(pid)
            stems.setdefault(p.stem.lower(), []).append(pid)
        self.unique = {k: v[0] for k, v in stems.items() if len(v) == 1}

    def resolve(self, target: str, page: Path | None) -> str | None:
        target = target.split("#")[0].strip().removesuffix(".md").rstrip("/")
        if not target:
            return None
        candidates = []
        if page is not None:
            try:
                candidates.append((page.resolve().parent / target).resolve()
                                  .relative_to(self.wiki).as_posix())
            except ValueError:
                pass
        candidates.append(target)
        for c in candidates:
            if c in self.pages:
                return c
            if f"{c}/README" in self.pages:
                return f"{c}/README"
        return self.unique.get(target.split("/")[-1].lower())


_resolvers: dict[Path, Resolver] = {}


def resolver() -> Resolver:
    root = paths.WIKI.resolve()
    if root not in _resolvers:
        _resolvers[root] = Resolver(root)
    return _resolvers[root]


def wikilink(target: str, label: str | None) -> str:
    """Replacement for one wikilink during cleaning."""
    text = label or target.rstrip("/").split("/")[-1].replace("-", " ")
    page_id = resolver().resolve(target, current_page.get())
    return mark(page_id, text) if page_id else text


# --------------------------------------------------------------------------- finalize

def rewrite_texts(sections: list, entities: list[dict[str, Any]], fn: Callable[[str, str, str], str]) -> None:
    """Apply fn(text, lang, owner_id) to every text field of the bundle content."""
    for s in sections:
        for u in s.units:
            for lang, t in list(u.text.items()):
                u.text[lang] = fn(t, lang, s.id)
            for lang, t in list(u.caption.items()):
                u.caption[lang] = fn(t, lang, s.id)
            for lang, rows in list(u.rows.items()):
                u.rows[lang] = [[fn(c, lang, s.id) for c in row] for row in rows]
    for e in entities:
        for u in e.get("units", []):
            for lang, t in list(u.get("text", {}).items()):
                u["text"][lang] = fn(t, lang, e["id"])
            for lang, rows in list(u.get("rows", {}).items()):
                u["rows"][lang] = [[fn(c, lang, e["id"]) for c in row] for row in rows]


@dataclass
class LinkStats:
    kept: int = 0
    dropped: Counter = field(default_factory=Counter)        # target page -> count
    auto: Counter = field(default_factory=Counter)           # term -> count
    dates_rewritten: int = 0
    dates_unconverted: list[str] = field(default_factory=list)


def finalize(sections: list, entities: list[dict[str, Any]], page_to_artefact: dict[str, str],
             artefacts: set[str], stats: LinkStats) -> None:
    """Point links at artefact ids; links to pages that don't ship become plain labels."""
    def target_of(page_id: str) -> str | None:
        if page_id in INDEX_FOR_PAGE:
            return INDEX_FOR_PAGE[page_id]
        aid = page_to_artefact.get(page_id, page_id)
        return aid if aid in artefacts else None

    def fix(text: str, _lang: str, _owner: str) -> str:
        def one(m: re.Match[str]) -> str:
            aid = target_of(m.group("id"))
            if aid:
                stats.kept += 1
                return mark(aid, m.group("label"))
            stats.dropped[m.group("id")] += 1
            return m.group("label")
        return MARK.sub(one, text)

    rewrite_texts(sections, entities, fix)
    for e in entities:
        rel = []
        for r in e.get("related", []):
            aid = target_of(r["id"])
            if aid and aid != e["id"] and all(x["id"] != aid for x in rel):
                rel.append({**r, "id": aid})
        e["related"] = rel


# --------------------------------------------------------------------------- dual dates

MONTHS = {
    "en": ["January", "February", "March", "April", "May", "June", "July", "August",
           "September", "October", "November", "December"],
    "ro": ["ianuarie", "februarie", "martie", "aprilie", "mai", "iunie", "iulie", "august",
           "septembrie", "octombrie", "noiembrie", "decembrie"],
    "fr": ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août",
           "septembre", "octobre", "novembre", "décembre"],
    "de": ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August",
           "September", "Oktober", "November", "Dezember"],
}


def julian_to_gregorian(y: int, m: int, d: int) -> date:
    """Julian calendar date -> proleptic Gregorian date (via the Julian Day Number)."""
    a = (14 - m) // 12
    yy, mm = y + 4800 - a, m + 12 * a - 3
    jdn = d + (153 * mm + 2) // 5 + 365 * yy + yy // 4 - 32083
    return date.fromordinal(jdn - 1721425)


def gregorian_to_julian(g: date) -> tuple[int, int, int]:
    jdn = g.toordinal() + 1721425
    c = jdn + 32082
    dd = (4 * c + 3) // 1461
    e = c - 1461 * dd // 4
    mm = (5 * e + 2) // 153
    day = e - (153 * mm + 2) // 5 + 1
    month = mm + 3 - 12 * (mm // 10)
    year = dd - 4800 + mm // 10
    return year, month, day


def dual_date(j: tuple[int, int, int], g: date, lang: str) -> str:
    names = MONTHS[lang]
    jy, jm, jd = j
    if (jy, jm) == (g.year, g.month):
        core = f"{jd} ({g.day}) {names[jm - 1]} {jy}"
    elif jy == g.year:
        core = f"{jd} {names[jm - 1]} ({g.day} {names[g.month - 1]}) {jy}"
    else:
        core = f"{jd} {names[jm - 1]} {jy} ({g.day} {names[g.month - 1]} {g.year})"
    return f"{core} {mark(DUAL_DATE, DUAL_TAG)}"


def _valid(y: int, m: int, d: int) -> bool:
    try:
        date(y, m, d)
        return True
    except ValueError:
        return y % 4 == 0 and m == 2 and d == 29          # Julian leap day in a non-Gregorian leap year


def _date_patterns(lang: str) -> list[re.Pattern[str]]:
    mon = "|".join(MONTHS[lang])
    return [
        # 25 December 1865 / 6 January 1866
        re.compile(rf"\b(?P<d1>\d{{1,2}}) (?P<m1>{mon}) (?P<y1>\d{{4}}) ?/ ?(?P<d2>\d{{1,2}}) (?P<m2>{mon}) (?P<y2>\d{{4}})\b"),
        # 24 January / 5 February 1859
        re.compile(rf"\b(?P<d1>\d{{1,2}}) (?P<m1>{mon}) ?/ ?(?P<d2>\d{{1,2}}) (?P<m2>{mon}) (?P<y>\d{{4}})\b"),
        # 1/13 June 1865
        re.compile(rf"\b(?P<d1>\d{{1,2}})/(?P<d2>\d{{1,2}}) (?P<m>{mon}) (?P<y>\d{{4}})\b"),
    ]


def convert_dual(m: re.Match[str], lang: str) -> str | None:
    """Return the DR-015 form of a matched dual date, or None if the pair is inconsistent."""
    idx = {n: i + 1 for i, n in enumerate(MONTHS[lang])}
    gd = m.groupdict()
    d1, d2 = int(gd["d1"]), int(gd["d2"])
    if "y1" in gd and gd.get("y1"):
        j = (int(gd["y1"]), idx[gd["m1"]], d1)
        g_claim = (int(gd["y2"]), idx[gd["m2"]], d2)
    elif gd.get("m1"):
        y = int(gd["y"])
        j = (y, idx[gd["m1"]], d1)
        g_claim = (y, idx[gd["m2"]], d2)
    else:
        y, mo = int(gd["y"]), idx[gd["m"]]
        j = (y, mo, d1)
        if not _valid(*j):
            return None
        g = julian_to_gregorian(*j)
        if g.day == d2:
            return dual_date(j, g, lang)
        # The month may name the Gregorian date ("30/11 May"): read it that way instead.
        try:
            g = date(y, mo, d2)
        except ValueError:
            return None
        jj = gregorian_to_julian(g)
        return dual_date(jj, g, lang) if jj[2] == d1 else None
    if not _valid(*j):
        return None
    g = julian_to_gregorian(*j)
    return dual_date(j, g, lang) if (g.year, g.month, g.day) == g_claim else None


# --------------------------------------------------------------------------- autolink

@dataclass
class Term:
    pattern: re.Pattern[str]
    target: str
    name: str


# Table 2 forms that mean something else in running text: "AT" (Stamp's Workshop) is
# also the Michel country code for Austria ("MI AT 1").
NOT_AUTOLINKED = {"AT"}


def build_terms(entities: list[dict[str, Any]], lang: str) -> list[Term]:
    """The curated auto-link vocabulary for one language."""
    terms: list[Term] = []
    forms: Counter = Counter()
    abbrs = [e for e in entities if e.get("type") == "abbreviation"]
    for e in abbrs:
        for f in e.get("forms", []):
            forms[f] += 1
    for e in abbrs:
        if e.get("category") == "country":
            continue                      # two-letter country codes collide with ordinary words
        target = e.get("see_id") or e["id"]
        for f in e.get("forms", []):
            # Only unambiguous, multi-character, all-capital forms: LP, AMS, UPU, M1, PM52.
            if forms[f] > 1 or f in NOT_AUTOLINKED or not re.fullmatch(r"[A-Z][A-Z0-9]+", f):
                continue
            terms.append(Term(re.compile(rf"(?<![\w/]){re.escape(f)}(?![\w/])"), target, f))
    for e in entities:
        if e.get("type") != "color":
            continue
        name = e.get("title", {}).get(lang)
        if name and len(name.split()) > 1:              # "Black"/"White" alone are too common
            terms.append(Term(re.compile(rf"(?<!\w){re.escape(name)}(?!\w)", re.IGNORECASE), e["id"], name))
        for sw in e.get("swatches", []):
            system = {"pantone": "Pantone", "ral": "RAL", "ams": "AMS", "ams-std": "AMS-STD"}.get(sw["system"])
            if system and sw.get("code"):
                code = re.escape(f"{system} {sw['code']}").replace(r"\ ", r"\s+")
                terms.append(Term(re.compile(rf"(?<![\w-]){code}(?![\w-])"), e["id"], f"{system} {sw['code']}"))
    # Longest first so "AMS-STD 17038" wins over "AMS".
    terms.sort(key=lambda t: -len(t.name))
    return terms


def autolink(text: str, lang: str, owner: str, terms: list[Term], stats: LinkStats) -> str:
    if not text:
        return text
    out_lines = []
    for line in text.split("\n"):
        if line.lstrip().startswith("#"):
            out_lines.append(line)                      # headings stay plain
            continue
        out_lines.append(_link_line(line, lang, owner, terms, stats))
    return "\n".join(out_lines)


def _link_line(line: str, lang: str, owner: str, terms: list[Term], stats: LinkStats) -> str:
    # Work only on the stretches outside existing links.
    parts, pos = [], 0
    for m in MARK.finditer(line):
        parts.append(_link_plain(line[pos:m.start()], lang, owner, terms, stats))
        parts.append(m.group(0))
        pos = m.end()
    parts.append(_link_plain(line[pos:], lang, owner, terms, stats))
    return "".join(parts)


def _link_plain(text: str, lang: str, owner: str, terms: list[Term], stats: LinkStats) -> str:
    if not text:
        return text
    # 1. Dual dates, rewritten into the DR-015 notation.
    if lang in MONTHS:
        for rx in _date_patterns(lang):
            def date_sub(m: re.Match[str]) -> str:
                new = convert_dual(m, lang)
                if new is None:
                    stats.dates_unconverted.append(m.group(0))
                    return m.group(0)
                stats.dates_rewritten += 1
                return new
            text = rx.sub(date_sub, text)
        if MARK.search(text):
            return _link_line(text, lang, owner, terms, stats)
    # 2. Calendar markers on single dates.
    def cal(m: re.Match[str]) -> str:
        stats.auto[m.group(0)] += 1
        return mark(JULIAN if m.group(1) == "J" else GREGORIAN, m.group(0))
    text = re.sub(r"\(([JG])\)", cal, text)
    if MARK.search(text):
        return _link_line(text, lang, owner, terms, stats)
    # 3. Vocabulary: first matching term wins, earliest position first.
    best = None
    for t in terms:
        if t.target == owner:
            continue
        m = t.pattern.search(text)
        if m and (best is None or m.start() < best[0].start()):
            best = (m, t)
    if best is None:
        return text
    m, t = best
    stats.auto[t.name] += 1
    return (text[:m.start()] + mark(t.target, m.group(0))
            + _link_plain(text[m.end():], lang, owner, terms, stats))


def autolink_all(sections: list, entities: list[dict[str, Any]], languages: Iterable[str],
                 stats: LinkStats) -> None:
    terms = {lang: build_terms(entities, lang) for lang in languages}

    def fn(text: str, lang: str, owner: str) -> str:
        return autolink(text, lang, owner, terms.get(lang) or terms["en"], stats)

    rewrite_texts(sections, entities, fn)


def report_lines(stats: LinkStats) -> list[str]:
    lines = [f"links kept: {stats.kept}",
             f"links to pages that don't ship (shown as plain text): {sum(stats.dropped.values())}",
             f"dual dates rewritten to DR-015 notation: {stats.dates_rewritten}",
             f"dual dates left as written (inconsistent day pair): {len(set(stats.dates_unconverted))}",
             f"auto-links: {sum(stats.auto.values())}", ""]
    lines += [f"  {n:5d}  {term}" for term, n in stats.auto.most_common()]
    if stats.dates_unconverted:
        lines += ["", "unconverted dates:"] + [f"  {d}" for d in sorted(set(stats.dates_unconverted))]
    lines += ["", "most linked pages that don't ship:"]
    lines += [f"  {n:5d}  {pid}" for pid, n in stats.dropped.most_common(40)]
    return lines

