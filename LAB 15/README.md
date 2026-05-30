# Bee RNG

## O grze
Bee RNG to prosta gra wykorzystująca mechaniki znane m.in. z platformy Roblox (takie jak Sol's RNG, Pet RNG). 
Gracz nie musi biegać i walczyć – skupiamy się na losowaniu pszczół, wyposażaniu tych najlepszych i zbieraniu pyłku. 
Zebrany pyłek pozwala nam z kolei inwestować w ulepszenia i poszerzać mapę.

Jak grać:
1. Klikasz przycisk `ROLL`, żeby wylosować pszczołę.
2. Otwierasz `BACKPACK` i wybierasz pszczołę lub używasz opcji `EQUIP BEST`, żeby automatycznie założyć najlepsze pszczoły.
3. Stojąc przy kwiatkach Twoje pszczoły zbierają pyłek który jest pokazany na liczniku z lewej strony.
4. Za pyłek kupujesz rzeczy w zakładce `UPGRADE`.
5. Po odblokowaniu wszystkich stref wygrywasz grę.

Poruszamy się za pomocą `WASD`, interfejs obsługujemy myszką.

## Technologia
Zrobiłem ten projekt na silniku Godot 4.x w języku GDScript.
Żeby go uruchomić wystarczy zaimportować plik `project.godot` w głównym panelu Godota i kliknąć przycisk "Uruchom" - gra ruszy ze sceny `res://scenes/ui/main_menu.tscn`.

## Wymagania techniczne

- FSM: gracz ma maszynę stanów w `scenes/characters/player/player.gd`, stany `IDLE` i `WALK`.
- Kolizje: gracz używa `CharacterBody2D`, kwiaty `Area2D`, a granice stref `StaticBody2D` z `CollisionShape2D`.
- Menu główne: `scenes/ui/main_menu.tscn`.
- Ekran końca gry: `scenes/ui/end_screen.tscn`.
- Audio: muzyka w tłe, muzyka menu, dźwięki UI, rollowania, zbierania pyłku, zakładania i kroków.

### Audio (Dźwięki)
Każdy plik dźwiękowy w mojej grze został pobrany z bazy http://www.freesound.org/.
Użyłem dźwięków do rollowania pszczół, klikania UI, zbierania pyłku i odblokowywania stref, a także pod same kroki gracza.

### Odpowiedź na podpunkt "Informacja czy projekt jest klonem — jeśli tak, podać tytuł oryginalnej gry"
Projekt jest inspirowany grami typu RNG, np. Sol's RNG oraz Pet RNG, ale nie jest bezpośrednim klonem jednego konkretnego tytułu.

## Błędy/Braki
- Brak wyłączenia muzyki i efektów dźwiękowych.
- Przez to, że ustawiłem losowe ceny gra może nie być zbalansowana.
- Wyłączenie gry sprawi, że zaczniemy na czysto.
- Planuje też dodać grę sieciową gdzie będzie można rywalizować z innymi graczami.