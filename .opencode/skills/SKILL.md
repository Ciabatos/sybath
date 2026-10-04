---
name: ui-panel-builder
description:
  Generuje UI wewnątrz istniejącego panelu, dopasowane do kontenera modala. Użyj, gdy użytkownik poda nazwę panelu i
  modala.
---

# UI Panel Builder

## Workflow (kolejność ma znaczenie)

Gdy użytkownik poda **panel** i **modal**, wykonaj:

### Krok 1 — Przeczytaj modal (kontener)

Odczytaj plik modala i jego CSS, np.:

- `components/modals/ModalTopCenter.tsx`
- `components/modals/styles/ModalTopCenter.module.css`

Zapisz sobie **kontener**:

- wymiary (width/height/max-\*),
- pozycja (top/left/right/bottom/transform),
- overflow,
- animacja,
- z-index.

To mówi Ci, ile miejsca ma panel i jak ma się „zmieścić”.

### Krok 2 — Przeczytaj panel (szkielet)

Odczytaj plik panelu wskazany przez użytkownika, np.:

- `components/players/CreatePlayerPanel.tsx`
- `components/players/styles/CreatePlayerPanel.module.css`

Zapamiętaj:

- nazwę komponentu (default export),
- istniejące importy (np. `Button`, `X`, hook modalny),
- strukturę: `overlay` → `panel` (i ewentualnie głębiej),
- klas CSS już zdefiniowane.

### Krok 3 — Wygeneruj UI

Dodaj UI **wewnątrz** `<div className={styles.panel}>`. Nie ruszaj `overlay` ani zamknięcia.

## Zasady generowania

1. **Dopasuj do kontenera modala**:
   - Jeśli modal ma `height: 100vh` i `width: 400px`, panel też ma wypełnić tę przestrzeń.
   - Jeśli modal ma `overflow-y: auto`, panel może być scrollowalny.
   - Nie wymyślaj własnych wymiarów — wynikają z modala.

2. **Mockuj dane**:
   ```tsx
   const mockPlayers = [
     { id: 1, name: "Gracz 1", level: 10 },
   ]
   Rozbijanie na komponenty:
   ```

Jeśli panel ma > ~80 linii JSX, wydziel sekcje:

text components/players/ ├── CreatePlayerPanel.tsx (parent) ├── CreatePlayerPanelForm.tsx ├── CreatePlayerPanelList.tsx
└── styles/ └── CreatePlayerPanel.module.css Parent importuje sekcje i składa je w <div className={styles.panel}>.

Style:

Dopisuj klasy do istniejącego .module.css panelu.

Nie nadpisuj .overlay ani .panel — chyba że użytkownik o to poprosi.

Nazwy camelCase.

Nie zmieniaj:

importów hooków modalnych,

funkcji zamykającej modal (resetModal\*),

istniejących importów (Button, ikony).
