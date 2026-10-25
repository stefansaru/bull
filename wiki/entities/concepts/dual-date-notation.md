---
id: entities/concepts/dual-date-notation
type: concept
title:
  en: "📅 Dual dates — how Julian and Gregorian dates are written"
  ro: "📅 Date duble — cum se scriu datele iuliene și gregoriene"
  fr: "📅 Doubles dates — écrire les dates julienne et grégorienne"
  de: "📅 Doppeldaten — wie julianische und gregorianische Daten geschrieben werden"
marker: "📅"
summary: "The first date is Julian (the calendar of the source), the date in parentheses is Gregorian: 1 (13) June 1865 ᴶ⁄ᴳ."
related:
  - "[[julian-calendar]]"
  - "[[gregorian-calendar]]"
refs:
  - "[[../../meta/decisions/DR-015-ui-concept|DR-015]]"
  - "[[../../meta/conventions|Conventions, C-04]]"
status: draft
---

# 📅 Dual dates — how Julian and Gregorian dates are written

When a date matters in both calendars, the app writes the **source calendar first**
— Julian for Moldavian documents of the period — and the **Gregorian equivalent in
parentheses**, followed by a small ᴶ⁄ᴳ tag that says which is which
([[../../meta/decisions/DR-015-ui-concept|DR-015]]):

| Case | Written as |
|---|---|
| Same month | 1 (13) June 1865 ᴶ⁄ᴳ |
| Different months | 24 January (5 February) 1859 ᴶ⁄ᴳ |
| Different years | 25 December 1865 (6 January 1866) ᴶ⁄ᴳ |
| A year or a range | 1858–1862 (no calendar claim) |

In the 19th century the Gregorian date is the Julian date plus 12 days; from March
1900 plus 13. A single date marked **(J)** is Julian, **(G)** Gregorian.

The wiki's own prose still uses the older compact form `1/13 June 1865`; the app
shows it in the notation above. See [[julian-calendar]] and [[gregorian-calendar]].
