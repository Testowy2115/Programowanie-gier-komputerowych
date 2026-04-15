# LAB 08

## Opis
Projekt realizuje finalne rozszerzenie i domknięcie gry Asteroids z Laboratorium 08.
Wprowadzono trzypoziomowy podział asteroid, w którym trafienie rozdziela asteroidę na mniejsze, szybsze fragmenty.
Zaimplementowano pełną maszynę stanów, pozwalającą na płynne przejścia między ekranami MENU, GAME i GAME_OVER.
Dodano system punktacji (score) wraz z wbudowanym HUD-em i zapisem najlepszego wyniku sesji (best score).
Gra przeszła refaktoryzację celem usunięcia długu technicznego.
Dodano obsługę warunków końca gry: wygraną (brak asteroid na planszy) i przegraną (kolizja statku).

## Uruchomienie
Aby uruchomić grę potrzeba zainstalować bibliotekę. 
Uruchamiamy wiersz poleceń i wklejamy poniższy kod:
pip install raylib

Grę uruchamiamy też z wiersza poleceń wklejając komendę:
python main.py