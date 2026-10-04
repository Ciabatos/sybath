# AGENTS.md

## Struktura projektu

- `components/players/` – panele (np. `CreatePlayerPanel.tsx`)
- `components/players/styles/` – style paneli (`.module.css`)
- `components/modals/` – modale (rodzice paneli)
- `components/modals/styles/` – style modali (`.module.css`)
- `methods/hooks/modals/` – hooki modalne (np. `useModalTopCenter`)
- `app\globals.css` - globalne style.

## Hierarchia

Modal (np. ModalTopCenter) └── Panel (np. CreatePlayerPanel) ├── Sekcja A (opcjonalnie) ├── Sekcja B (opcjonalnie) └──
...

text

- **Modal** = rodzic najwyższego poziomu. Definiuje kontener, animację, pozycję.
- **Panel** = dziecko modala. Wypełnia kontener UI.
- **Sekcje** = opcjonalne mniejsze komponenty. Rodzicem zawsze pozostaje Panel.

## Twarde zasady

1. **Nie modyfikuj logiki** – nie ruszaj importów, hooków, `onClick` zamykających modal.
2. **Nie zmieniaj modala** – modal jest tylko do odczytu (żeby poznać kontener).
3. **UI tylko w panelu** – cały wygenerowany kod trafia do pliku panelu i jego `.module.css`.
4. **Mockuj dane** – brak `fetch`/`axios`. Stałe w pliku panelu.
5. **Rozbijaj na komponenty** – jeśli panel jest złożony, twórz pliki w tym samym katalogu, ale Panel pozostaje
   rodzicem.
6. **CSS Modules** – bez Tailwinda.
