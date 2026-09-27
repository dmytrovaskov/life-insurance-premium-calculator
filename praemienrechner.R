## ============================================================
## Prämienrechner Lebensversicherung
## Basierend auf der Sterbetafel 2020/2022 der Statistik Austria
## ============================================================

rm(list = ls())

# --- Pakete -----------------------------------------------------
# install.packages("readODS")
# install.packages("ggplot2")
library(readODS)
library(ggplot2)


## ============================================================
## 1) Sterbetafel einlesen und bereinigen
## ============================================================

tafel <- read_ods(
  "Ausfuehrliche_allgemeine_und_ausgeglichene_Sterbetafeln_186871_bis_202022.ods",
  sheet = "2020_2022_weiblich",
  skip  = 5
)

names(tafel) <- c("x", "qx", "lx", "dx", "Lx", "Tx", "ex")
tafel$x <- as.numeric(tafel$x)     # letzte Zeilen (Fußnoten) werden zu NA
tafel   <- tafel[!is.na(tafel$x), ]

# Kontrolle
range(tafel$x)      
nrow(tafel)          # sollte um 1 groesser als 2. Wert in range(tafel$x) sein
sum(is.na(tafel))    # sollte 0 sein


## ============================================================
## 2) Explorative Grafik: Sterbewahrscheinlichkeit vs. Alter
## ============================================================

ggplot(tafel, aes(x = x, y = qx)) +
  geom_line() +
  labs(title = "Sterbewahrscheinlichkeit q(x) nach Alter",
       x = "Alter x", y = "q(x)")

ggplot(tafel, aes(x = x, y = qx)) +
  geom_line() +
  scale_y_log10() +
  labs(title = "Sterbewahrscheinlichkeit q(x) nach Alter (log-Skala)",
       x = "Alter x", y = "q(x), logarithmisch")


## ============================================================
## 3) Grundfunktion: n-jährige Überlebenswahrscheinlichkeit
##    npx(x, n) = l(x+n) / l(x)
## ============================================================

npx <- function(x, n, tafel) {
  lx  <- tafel[tafel$x == x, ]$lx
  lxn <- tafel[tafel$x == x + n, ]$lx
  return(lxn / lx)
}


## ============================================================
## 4) Nettoeinmalprämie – Ablebensversicherung (Todesfall)
##    NEP = S * Summe_k [ v^(k+1) * kpx * q(x+k) ],  k = 0 .. n-1
## ============================================================

nep_ableben <- function(x, n, i, S, tafel) {
  v <- 1 / (1 + i)
  
  summe <- 0
  for (k in 0:(n - 1)) {
    kpx        <- npx(x, k, tafel)
    qxk        <- tafel[tafel$x == x + k, ]$qx
    v_k        <- v^(k + 1)
    neuer_term <- v_k * kpx * qxk
    summe      <- summe + neuer_term
  }
  
  return(summe * S)
}


## ============================================================
## 5) Nettoeinmalprämie – Erlebensversicherung
##    NEP = S * v^n * npx(x, n)
## ============================================================

nep_erleben <- function(x, n, i, S, tafel) {
  v   <- 1 / (1 + i)
  kpx <- npx(x, n, tafel)
  return(v^n * kpx * S)
}


## ============================================================
## 6) Nettoeinmalprämie – Gemischte Versicherung
##    NEP = NEP(Ableben) + NEP(Erleben)
## ============================================================

nep_gemischt <- function(x, n, i, S, tafel) {
  nep_ableben(x, n, i, S, tafel) + nep_erleben(x, n, i, S, tafel)
}


## ============================================================
## 7) Vorschüssige, befristete Leibrente
##    ä(x:n) = Summe_k [ v^k * kpx ],  k = 0 .. n-1
## ============================================================

annuity_due <- function(x, n, i, tafel) {
  v <- 1 / (1 + i)
  
  summe <- 0
  for (k in 0:(n - 1)) {
    v_k        <- v^k
    kpx        <- npx(x, k, tafel)
    neuer_term <- v_k * kpx
    summe      <- summe + neuer_term
  }
  
  return(summe)
}


## ============================================================
## 8) Jahresprämie = Nettoeinmalprämie / Leibrente
## ============================================================

jahrespraemie <- function(x, n, i, S, tafel) {
  nep <- nep_ableben(x, n, i, S, tafel)
  ank <- annuity_due(x, n, i, tafel)
  return(nep / ank)
}


## ============================================================
## 9) Tests und Plausibilitätsprüfungen
## ============================================================

# npx: Randfälle
npx(60, 0, tafel)     # muss exakt 1 sein
npx(43, 5, tafel)
npx(100, 5, tafel)

# nep_ableben: sollte mit wachsendem n steigen
nep_ableben(60, 1, 0.04, 50000, tafel)
nep_ableben(60, 2, 0.04, 50000, tafel)
nep_ableben(60, 3, 0.04, 50000, tafel)

# annuity_due: Rentenfaktor für 3 Jahre
annuity_due(60, 3, 0.04, tafel)

# Jahresprämie für eine 3-jährige Ablebensversicherung
jahrespraemie(60, 3, 0.04, 50000, tafel)

# Konsistenzcheck: Ableben + Erleben (n=1) muss der abgezinsten
# Summe entsprechen, da eines von beidem sicher eintritt
i <- 0.04
v <- 1 / (1 + i)
S <- 50000

all.equal(
  nep_ableben(60, 1, i, S, tafel) + nep_erleben(60, 1, i, S, tafel),
  S * v
)

# Gemischte Versicherung
nep_gemischt(60, 1, 0.04, 50000, tafel)
