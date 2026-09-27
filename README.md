# Life Insurance Premium Calculator

Ein kleines R-Projekt zur Berechnung von Nettoeinmalprämien und laufenden Jahresprämien
für Lebensversicherungsprodukte, basierend auf einer echten Sterbetafel der
**Statistik Austria** (Sterbetafel 2020/2022).

Das Projekt setzt die versicherungsmathematischen Grundlagen (Äquivalenzprinzip,
Barwertrechnung, Sterbetafel) direkt in R-Funktionen um und prüft jede Funktion
gegen Handrechnungen bzw. Konsistenzchecks.

## Funktionen

| Funktion | Beschreibung |
|---|---|
| `npx(x, n, tafel)` | n-jährige Überlebenswahrscheinlichkeit einer x-jährigen Person: <br>`npx = l(x+n) / l(x)` |
| `nep_ableben(x, n, i, S, tafel)` | Nettoeinmalprämie einer n-jährigen **Ablebensversicherung** (Todesfallleistung S) |
| `nep_erleben(x, n, i, S, tafel)` | Nettoeinmalprämie einer n-jährigen **Erlebensversicherung** (Leistung S bei Überleben der Laufzeit) |
| `nep_gemischt(x, n, i, S, tafel)` | Nettoeinmalprämie einer **gemischten Versicherung** (Ableben + Erleben) |
| `annuity_due(x, n, i, tafel)` | Vorschüssige, befristete **Leibrente** ä(x:n) |
| `jahrespraemie(x, n, i, S, tafel)` | Laufende **Jahresprämie**, umgerechnet aus der Nettoeinmalprämie über die Leibrente |

**Parameter:**
- `x` – Alter der versicherten Person zu Vertragsbeginn
- `n` – Laufzeit in Jahren
- `i` – Rechnungszins (z. B. `0.04` für 4 %)
- `S` – Versicherungssumme
- `tafel` – die eingelesene Sterbetafel (siehe unten)

## Datengrundlage

Die verwendete Sterbetafel stammt von der Statistik Austria:
[Ausführliche allgemeine und ausgeglichene Sterbetafeln](https://www.statistik.at/),
verwendet wird das Tabellenblatt `2020_2022_männlich`.

Die Rohdatei liegt im `.ods`-Format vor und wird mit dem Paket `readODS` eingelesen.
Enthaltene Spalten (nach Umbenennung):

| Spalte | Bedeutung |
|---|---|
| `x` | Alter |
| `qx` | Sterbewahrscheinlichkeit im Alter x |
| `lx` | Überlebende im Alter x (Basis 100.000) |
| `dx` | Gestorbene im Altersintervall x bis x+1 |
| `Lx`, `Tx`, `ex` | Personenjahre, kumulierte Personenjahre, fernere Lebenserwartung (aktuell ungenutzt) |

## Verwendung

```r
library(readODS)
library(ggplot2)

# Sterbetafel einlesen (Pfad ggf. anpassen)
tafel <- read_ods(
  "Ausfuehrliche_allgemeine_und_ausgeglichene_Sterbetafeln_186871_bis_202022.ods",
  sheet = "2020_2022_männlich",
  skip  = 5
)

# Beispiel: 3-jährige Ablebensversicherung, 60-jährige Person,
# Summe 50.000 €, Rechnungszins 4 %
nep_ableben(60, 3, 0.04, 50000, tafel)
jahrespraemie(60, 3, 0.04, 50000, tafel)
```

## Tests / Plausibilitätsprüfungen

Das Skript enthält mehrere eingebaute Kontrollen:

- `npx(x, 0, tafel)` muss exakt `1` ergeben
- `nep_ableben()` muss mit wachsendem `n` monoton steigen
- Für `n = 1` muss gelten:
  `nep_ableben(x, 1, i, S, tafel) + nep_erleben(x, 1, i, S, tafel) == S * v`
  (eines der beiden Ereignisse – Tod oder Überleben – tritt in einem Jahr sicher ein),
  geprüft mit `all.equal()`



## Geplante Erweiterungen

- VBA/Excel-Version als Frontend (z.B. für den Vertrieb)
- Berücksichtigung eines Sicherheitszuschlags
- Deckungskapitalberechnung während der Laufzeit
