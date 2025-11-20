# Sybath — Projekt MMO (CV projektu)

## Krótkie podsumowanie
Sybath to zaawansowany, database-driven MMO (massively multiplayer online) zbudowany w Next.js. Projekt demonstruje projektowanie większych systemów webowych: architekturę opartą na schematach bazy danych, automatyczne generowanie backendu przy użyciu PlopJS oraz modularne podejście do API i warstwy klienta.

## Rola projektu (jak w CV)
- **Cel:** Pokazać zdolność do projektowania skalowalnych aplikacji webowych z silnym rozgraniczeniem odpowiedzialności pomiędzy bazą danych, generowanym backendem i frontendem.
- **Moje obowiązki / Co projekt prezentuje:** architektura aplikacji, automatyzacja generowania CRUD/API za pomocą `PlopJS`, projektowanie schematów bazy danych, implementacja fetcherów i akcji, integracja z Next.js (app router), tworzenie komponentów UI i hooków do synchronizacji stanu.

## Najważniejsze cechy
- **Database-driven development:** logika i struktura API generowane częściowo na podstawie schematów DB i szablonów — minimalizacja ręcznie pisanych endpointów.
- **Automatyczne generatory (PlopJS):** repo zawiera `plopfile.js` oraz katalog `plop-templates/` używany do szybkiego scaffoldingu akcji, fetcherów, hooków i modeli.
- **Modularny backend:** API zorganizowane w `app/api/` z podziałem na tabele / zasoby (np. `map`, `players`, `items`).
- **Nowoczesny frontend:** Next.js + SWR (provider w `providers/swr-provider.tsx`), komponenty React w `components/`, modularne hooki w `methods/hooks/`.
- **Testowalność i automatyzacja:** pliki generujące kod upraszczają dodawanie nowych zasobów zgodnie z wzorcem.

## Techniczne szczegóły (Stack)
- **Frontend:** Next.js (app router), React, SWR
- **Backend:** API routes w Next.js (database-driven controllers)
- **Generatory:** PlopJS (`plopfile.js`, `plop-templates/`)
- **Baza danych:** PostgreSQL (katalog `db/`, dumpy i skrypty)
- **Inne:** TypeScript, postcss, plop, narzędzia developerskie (plop generators)

## Gdzie szukać kluczowych elementów w repozytorium
- `plopfile.js` — konfiguracja PlopJS i generatorów.
- `plop-templates/` — szablony używane do generowania akcji, fetcherów, hooków i tabel.
- `db/` — kopie zapasowe, skrypty i schematy bazy danych.
- `app/api/` — wygenerowane i ręcznie napisane endpointy API.
- `methods/` i `lib/` — fetchery, akcje i pomocnicze funkcje biznesowe.

## Przykłady zadań pokazowych (rekrutacyjne)
- Dodaj nowy zasób (np. `events`) używając PlopJS: pokaż jak generator tworzy fetchery, akcje i API.
- Wyjaśnij przepływ: zmiana schematu DB → wygenerowanie endpointów → użycie fetchera po stronie klienta.
- Zaprojektuj i zaimplementuj nową akcję (np. dodanie itemu do inwentarza) i test integracyjny.

## Co projekt pokazuje rekruterowi / pracodawcy
- Dojrzałe podejście architektoniczne: separacja warstw, powtarzalność i automatyzacja pracy programisty.
- Umiejętność pracy z bazą danych jako pierwszym źródłem prawdy (DB-driven design).
- Doświadczenie z narzędziami automatyzującymi pracę zespołu (PlopJS) i tworzenie szablonów przyspieszających rozwój.
- Zrozumienie nowoczesnego ekosystemu React/Next.js i wzorców fetchowania danych (SWR, fetchery, hooki).

## Jak uruchomić lokalnie (krótkie kroki)
1. `npm install`
2. Skonfiguruj połączenie z PostgreSQL (zmienne środowiskowe `.env`)
3. Załaduj schematy / dumpy z katalogu `db/` jeśli chcesz mieć przykładowe dane
4. `npm run dev` — uruchamia Next.js w trybie deweloperskim

## Link do repozytorium / demo
Umieść link do repozytorium lub demo tutaj (jeśli dotyczy) — ten projekt działa jako dobre portfolio techniczne przy aplikowaniu na stanowiska full-stack / backend / platform.

---

Plik ten służy jako gotowy opis projektu w formie „CV projektu” — możesz użyć go w aplikacji rekrutacyjnej, w portfolio lub do przygotowania case study podczas rozmowy technicznej.
