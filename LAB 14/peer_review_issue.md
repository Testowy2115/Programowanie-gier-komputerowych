# Peer review - Lab 14

- [ ] Projekt uruchamia sie bez bledow w konsoli Godot.
- [ ] Szyna PathFollow3D dziala - kamera jedzie do przodu.
- [ ] Strzelanie i kolizje dzialaja - wrogowie gina, wynik rosnie.
- [ ] Boss ma co najmniej dwa stany z roznym zachowaniem.
- [ ] HUD wyswietla wynik, HP i zycia.
- [ ] GameManager jest Autoloadem w Project Settings.
- [ ] Brak magicznych liczb w glownych skryptach.
- [ ] Refaktoryzacja ma co najmniej 3 commity z opisem kategorii.

Fragment kodu wart zachowania:
FSM bossa w `boss.gd` jest rozdzielony na `enter_state`, `start_idle`, `start_attack`, `start_retreat` i `start_death`, dzieki czemu zachowania stanow sa czytelne.

Konkretna sugestia poprawy:
Warto dodac pasek HP bossa w HUD, widoczny tylko podczas walki z bossem.
