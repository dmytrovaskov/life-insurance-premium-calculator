Option Explicit

' Praemienrechner Lebensversicherung
' Basierend auf der Sterbetafel 2020/2022 der Statistik Austria
' Tabellenblatt: Spalte A = Alter (x), Spalte B = qx, Spalte C = lx
' erste Datenzeile = Zeile 2, erstes Alter = 55

Const startAlter As Integer = 55
Const spalte_qx As Integer = 2
Const spalte_lx As Integer = 3

' n-jaehrige Ueberlebenswahrscheinlichkeit
' npx = l(x+n) / l(x)
Function Npx(x As Integer, n As Integer) As Double
    Dim zeileX As Integer
    Dim zeileXN As Integer
    Dim lx As Double
    Dim lxn As Double
    
    zeileX = x - startAlter + 2
    zeileXN = (x + n) - startAlter + 2
    
    lx = Cells(zeileX, spalte_lx).Value
    lxn = Cells(zeileXN, spalte_lx).Value
    
    Npx = lxn / lx
End Function

' Nettoeinmalprämie Ablebensversicherung, n Jahre
' NEP = S * Summe[k=0 bis n-1] v^(k+1) * kpx * q(x+k)
Function NepAbleben(x As Integer, n As Integer, zins As Double, S As Double) As Double
    Dim v As Double
    Dim summe As Double
    Dim k As Integer
    Dim kpx As Double
    Dim qxk As Double
    Dim zeile As Integer
    Dim vk As Double
    Dim neuer_betrag As Double
    
    v = 1 / (1 + zins)
    summe = 0
    
    For k = 0 To n - 1
        kpx = Npx(x, k)
        zeile = x + k - startAlter + 2
        qxk = Cells(zeile, spalte_qx).Value
        vk = v ^ (k + 1)
        neuer_betrag = kpx * qxk * vk
        summe = summe + neuer_betrag
    Next k
    
    NepAbleben = S * summe
End Function

' Nettoeinmalpraemie - Erlebensversicherung, n Jahre
' NEP = S * v^n * npx
Function NepErleben(x As Integer, n As Integer, zins As Double, S As Double) As Double
    Dim v As Double
    Dim kpx As Double
    
    v = 1 / (1 + zins)
    kpx = Npx(x, n)
    
    NepErleben = v ^ n * kpx * S
End Function

' Nettoeinmalpraemie - Gemischte Versicherung
' NEP = NEP(Ableben) + NEP(Erleben)
Function NepGemischt(x As Integer, n As Integer, zins As Double, S As Double) As Double
    NepGemischt = NepAbleben(x, n, zins, S) + NepErleben(x, n, zins, S)
End Function

' Vorschuessige, befristete Leibrente
' ae(x:n) = Summe[k=0 bis n-1] v^k * kpx
Function AnnuityDue(x As Integer, n As Integer, zins As Double) As Double
    Dim v As Double
    Dim summe As Double
    Dim k As Integer
    Dim kpx As Double
    Dim zeile As Integer
    Dim vk As Double
    Dim neuer_betrag As Double
    
    v = 1 / (1 + zins)
    summe = 0
    
    For k = 0 To n - 1
        kpx = Npx(x, k)
        vk = v ^ k
        neuer_betrag = vk * kpx
        summe = summe + neuer_betrag
    Next k
    
    AnnuityDue = summe
End Function

' Jahrespraemie = Nettoeinmalpraemie / Leibrente
Function Jahrespraemie(x As Integer, n As Integer, zins As Double, S As Double) As Double
    Dim nep As Double
    Dim ank As Double
    
    nep = NepAbleben(x, n, zins, S)
    ank = AnnuityDue(x, n, zins)
    
    Jahrespraemie = nep / ank
End Function

