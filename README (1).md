# Life Insurance Premium Calculator

Ein kleines Projekt zur Berechnung von Nettoeinmalprämien und laufenden Jahresprämien
für Lebensversicherungsprodukte, basierend auf einer echten Sterbetafel der
**Statistik Austria** (Sterbetafel 2020/2022). Dieselbe versicherungsmathematische
Logik ist **zweimal unabhängig implementiert**: einmal in **R**, einmal in **VBA**
(als Excel-Funktionen).

Jede Funktion wurde gegen Handrechnungen bzw. Konsistenzchecks geprüft (siehe
Abschnitt "Tests" unten).

## Funktionen

| Funktion (R) | Funktion (VBA) | Beschreibung |
|---|---|---|
| `npx(x, n, tafel)` | `Npx(x, n)` | n-jährige Überlebenswahrscheinlichkeit: `l(x+n) / l(x)` |
| `nep_ableben(x, n, i, S, tafel)` | `NepAbleben(x, n, zins, S)` | Nettoeinmalprämie einer n-jährigen **Ablebensversicherung** |
| `nep_erleben(x, n, i, S, tafel)` | `NepErleben(x, n, zins, S)` | Nettoeinmalprämie einer n-jährigen **Erlebensversicherung** |
| `nep_gemischt(x, n, i, S, tafel)` | `NepGemischt(x, n, zins, S)` | Nettoeinmalprämie einer **gemischten Versicherung** |
| `annuity_due(x, n, i, tafel)` | `AnnuityDue(x, n, zins)` | Vorschüssige, befristete **Leibrente** ä(x:n) |
| `jahrespraemie(x, n, i, S, tafel)` | `Jahrespraemie(x, n, zins, S)` | Laufende **Jahresprämie**, aus NEP über die Leibrente |

**Parameter:**
- `x` – Alter der versicherten Person zu Vertragsbeginn
- `n` – Laufzeit in Jahren
- `i` / `zins` – Rechnungszins (z. B. `0.04` für 4 %)
- `S` – Versicherungssumme
- `tafel` (nur R) – die eingelesene Sterbetafel als Dataframe

## Datengrundlage

Die verwendete Sterbetafel stammt von der Statistik Austria:
[Ausführliche allgemeine und ausgeglichene Sterbetafeln](https://www.statistik.at/),
verwendet wird das Tabellenblatt `2020_2022_männlich`.

| Spalte | Bedeutung |
|---|---|
| `x` | Alter |
| `qx` | Sterbewahrscheinlichkeit im Alter x |
| `lx` | Überlebende im Alter x (Basis 100.000) |

## Projektstruktur

```
life-insurance-premium-calculator/
├── R/
│   └── praemienrechner.R        # vollständige Implementierung in R
├── VBA/
│   └── praemienrechner.bas      # vollständige Implementierung in VBA
├── README.md
├── LICENSE
└── .gitignore
```

## R: Verwendung

```r
library(readODS)
library(ggplot2)

tafel <- read_ods(
  "Ausfuehrliche_allgemeine_und_ausgeglichene_Sterbetafeln_186871_bis_202022.ods",
  sheet = "2020_2022_männlich",
  skip  = 5
)

nep_ableben(60, 3, 0.04, 50000, tafel)
jahrespraemie(60, 3, 0.04, 50000, tafel)
```

## VBA: Verwendung

1. Sterbetafel (Spalten x, qx, lx, erste Datenzeile = Zeile 2) in ein Excel-Tabellenblatt
   einfügen.
2. `praemienrechner.bas` über den VBA-Editor importieren
   (Rechtsklick im Projekt-Explorer → Datei importieren...).
3. Die Funktionen direkt als Excel-Formeln verwenden:

```
=NepAbleben(60;3;0,04;50000)
=Jahrespraemie(60;3;0,04;50000)
```

(Je nach Excel-Spracheinstellung werden Funktionsargumente mit `;` statt `,`
getrennt.)

## Tests / Plausibilitätsprüfungen

Beide Implementierungen wurden unter anderem gegen folgende Kontrollen geprüft:

- `npx(x, 0)` muss exakt `1` ergeben
- `nep_ableben()` steigt monoton mit wachsendem `n`
  (mehr Jahre = mehr Gelegenheiten für den Todesfall)
- `nep_erleben()` **sinkt** monoton mit wachsendem `n`
  (längere Laufzeit = unwahrscheinlicheres Überleben bis zum Ende, stärkere Abzinsung)
- Für `n = 1` gilt: `nep_ableben + nep_erleben ≈ S · v`
  (eines der beiden Ereignisse – Tod oder Überleben – tritt in einem Jahr sicher ein),
  in R geprüft mit `all.equal()`
- `jahrespraemie() = nep_ableben() / annuity_due()`, direkt als Kontrollzeile
  nachgerechnet

Eine konkrete Testdokumentation mit Beispielwerten (60-jährige Person, Laufzeiten
1–3 Jahre, Summe 70.000 €) liegt als Screenshot im Ordner `VBA/` bei.

## Motivation

Das Projekt entstand als Vorbereitung auf eine Bewerbung als Junior Mathematiker
im Bereich Lebensversicherung, um versicherungsmathematische Konzepte aus dem
Studium (Barwertrechnung, Äquivalenzprinzip, Sterbetafeln) praktisch umzusetzen,
sowohl in R als auch in VBA, und mit echten Daten gegen Handrechnungen zu testen.

## Geplante Erweiterungen

- Sicherheitszuschlag auf die Nettoprämie
- Deckungskapitalberechnung während der Laufzeit
- Einfaches Excel-Frontend (Eingabemaske + automatische Berechnung über mehrere Zeilen)
