# LAB 07

## Opis
Projekt realizuje kolejne rozszerzenie gry Asteroids.
Dodano możliwość strzelania pociskami, dźwięki strzałów i eksplozji, a także kolizje pocisków z asteroidami na podstawie odległości euklidesowej (kolizja kołowa).
Wprowadzono zarządzanie cyklem życia zasobów (ręczne ładowanie i zwalnianie tekstur oraz dźwięków w Raylib) oraz zarządzanie dynamicznymi listami obiektów (pociski i eksplozje posiadające atrybut czas życia - TTL).
Zaimplementowano również animację eksplozji tworzoną w miejscu zniszczonej asteroidy oraz dodano teksturę/tło z gwiazdami.

## Uruchomienie
Aby uruchomić grę potrzeba zainstalować bibliotekę. 
Uruchamiamy wiersz poleceń i wklejamy poniższy kod:
pip install raylib

Grę uruchamiamy też z wiersza poleceń wklejając komendę:
python main.py