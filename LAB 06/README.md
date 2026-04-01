# LAB 06

## Opis
Projekt realizuje rozszerzenie gry Asteroids.
Statek i asteroidy poruszają się w przestrzeni toroidalnej (uciekając za krawędź ekranu, pojawiają się po przeciwnej stronie).
Zaimplementowano renderowanie "widm" (ghost rendering), co pozwala na płynne przechodzenie obiektów przez krawędzie, tak aby były widoczne po obu stronach jednocześnie.
Dodano poruszające się asteroidy o proceduralnie generowanych, nieregularnych kształtach (wielokątach). Logika matematyczna została wydzielona do pliku utils.

## Uruchomienie
Aby uruchomić grę potrzeba zainstalować bibliotekę. 
Uruchamiamy wiersz poleceń i wklejamy poniższy kod:
pip install raylib

Grę uruchamiamy też z wiersza poleceń wklejając komendę:
python main.py