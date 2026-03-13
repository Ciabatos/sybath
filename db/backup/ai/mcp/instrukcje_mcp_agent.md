# Instrukcje dla agenta AI — budowa MCP serwera dla gry RPG

## Kontekst projektu

Tworzysz MCP (Model Context Protocol) serwer dla gry RPG opartej na PostgreSQL. Baza danych jest podzielona na schematy. Funkcje w bazie mają komentarze określające ich rolę w API — jest to kluczowa informacja przy mapowaniu ich na narzędzia MCP.

---

## Architektura bazy danych — schematy i tabele

### Schema `attributes`
- `abilities` — zdolności (id, name, description, image)
- `skills` — umiejętności (id, name, description, image)
- `stats` — statystyki (id, name, description, image)
- `roles` — role (id, name)
- `player_abilities` — zdolności gracza (id, player_id, ability_id, value)
- `player_skills` — umiejętności gracza (id, player_id, skill_id, value)
- `player_stats` — statystyki gracza (id, player_id, stat_id, value)
- `ability_skill_requirements` — wymagania umiejętności dla zdolności
- `ability_stat_requirements` — wymagania statystyk dla zdolności

### Schema `auth`
- `users` — użytkownicy systemu (id, name, email, emailVerified, image, password)
- `accounts` — konta OAuth (id, userId, provider, providerAccountId, ...)
- `sessions` — sesje użytkowników
- `verification_token` — tokeny weryfikacyjne

### Schema `buildings`
- `building_types` — typy budynków (id, name, image_url)
- `buildings` — budynki (id, city_id, city_tile_x, city_tile_y, building_type_id, name)
- `building_roles` — role graczy w budynkach

### Schema `cities`
- `cities` — miasta (id, map_id, map_tile_x, map_tile_y, name, move_cost, image_url)
- `city_tiles` — kafelki miast (city_id, x, y, terrain_type_id, landscape_type_id)
- `city_roles` — role graczy w miastach

### Schema `districts`
- `district_types` — typy dzielnic (id, name, move_cost, image_url)
- `districts` — dzielnice (id, map_id, map_tile_x, map_tile_y, district_type_id, name)
- `district_roles` — role graczy w dzielnicach

### Schema `inventory`
- `inventory_containers` — kontenery ekwipunku (id, inventory_size, inventory_container_type_id, owner_id)
- `inventory_container_types` — typy kontenerów (1=gracz, 2=gear gracza, 3=budynek, 4=dzielnica)
- `inventory_slots` — sloty ekwipunku (id, inventory_container_id, item_id, quantity, inventory_slot_type_id)
- `inventory_slot_types` — typy slotów (1=zwykły, pozostałe=gear/equipment)
- `inventory_slot_type_item_type` — mapowanie typów slotów na typy przedmiotów
- `inventory_container_player_access` — dostęp gracza do kontenerów

### Schema `items`
- `items` — przedmioty (id, name, description, image, item_type_id)
- `item_types` — typy przedmiotów
- `item_stats` — statystyki przedmiotów (id, item_id, stat_id, value)

### Schema `knowledge`
- `known_map_tiles` — znane kafelki mapy przez gracza
- `known_map_tiles_resources` — znane zasoby na kafelkach
- `known_players_positions` — znane pozycje innych graczy
- `known_players_profiles` — znane profile innych graczy
- `known_players_abilities` — znane zdolności innych graczy
- `known_players_skills` — znane umiejętności innych graczy
- `known_players_stats` — znane statystyki innych graczy
- `known_players_containers` — znane ekwipunki innych graczy
- `known_players_squad_profiles` — znane profile graczy z drużyny

### Schema `players`
- `players` — gracze (id, user_id, name, image_map, image_portrait, is_active, second_name, nickname, masked_id)

### Schema `squad`
- `squads` — drużyny (id)
- `squad_players` — przynależność graczy do drużyn (squad_id, player_id)

### Schema `tasks`
- `tasks` — zadania asynchroniczne (id, player_id, status, created_at, scheduled_at, last_executed_at, error, method_name, method_parameters)
- `status_types` — typy statusów zadań (1=pending, 2=running, 3=done, 4=retry, 5=cancelled)

### Schema `world`
- `maps` — mapy (id, name)
- `map_tiles` — kafelki mapy (map_id, x, y, terrain_type_id, landscape_type_id)
- `terrain_types` — typy terenu (id, name, move_cost, image_url)
- `landscape_types` — typy krajobrazu (id, name, move_cost, image_url)
- `map_regions` — regiony mapy (id, name, region_type_id, image_outline, image_fill)
- `region_types` — typy regionów
- `map_tiles_map_regions` — przypisanie kafelków do regionów
- `map_tiles_players_positions` — pozycje graczy na mapie
- `map_tiles_resources` — zasoby na kafelkach (id, map_id, map_tile_x, map_tile_y, item_id, quantity)

### Widoki (`world`)
- `world.v_buildings` — budynki z typem i obrazkiem
- `world.v_districts` — dzielnice z typem, kosztem ruchu i obrazkiem

---

## Klasyfikacja funkcji bazodanowych i ich mapowanie na narzędzia MCP

Funkcje w bazie są oznaczone komentarzem SQL. Na tej podstawie tworzysz narzędzia MCP.

### Kategoria 1: `automatic_get_api`
Funkcje automatycznie wygenerowane dla tabel słownikowych. Zwracają dane referencyjne (niezmienne lub rzadko zmieniane). Mają dwa warianty:
- `get_X()` — zwraca wszystkie rekordy z tabeli
- `get_X_by_key(p_id)` — zwraca pojedynczy rekord po kluczu głównym

**Lista funkcji `automatic_get_api`:**
| Funkcja | Opis |
|---|---|
| `attributes.get_abilities()` | Wszystkie zdolności |
| `attributes.get_abilities_by_key(p_id)` | Zdolność po ID |
| `attributes.get_roles()` | Wszystkie role |
| `attributes.get_roles_by_key(p_id)` | Rola po ID |
| `attributes.get_skills()` | Wszystkie umiejętności |
| `attributes.get_skills_by_key(p_id)` | Umiejętność po ID |
| `attributes.get_stats()` | Wszystkie statystyki |
| `attributes.get_stats_by_key(p_id)` | Statystyka po ID |
| `buildings.get_building_types()` | Wszystkie typy budynków |
| `buildings.get_building_types_by_key(p_id)` | Typ budynku po ID |
| `buildings.get_buildings()` | Wszystkie budynki |
| `buildings.get_buildings_by_key(p_city_id)` | Budynki po ID miasta |
| `cities.get_cities()` | Wszystkie miasta |
| `cities.get_cities_by_key(p_map_id)` | Miasta po ID mapy |
| `cities.get_city_tiles()` | Wszystkie kafelki miast |
| `cities.get_city_tiles_by_key(p_city_id)` | Kafelki danego miasta |
| `districts.get_district_types()` | Wszystkie typy dzielnic |
| `districts.get_district_types_by_key(p_id)` | Typ dzielnicy po ID |
| `districts.get_districts()` | Wszystkie dzielnice |
| `districts.get_districts_by_key(p_map_id)` | Dzielnice po ID mapy |
| `inventory.get_inventory_slot_types()` | Wszystkie typy slotów |
| `inventory.get_inventory_slot_types_by_key(p_id)` | Typ slotu po ID |
| `items.get_item_stats()` | Wszystkie statystyki przedmiotów |
| `items.get_item_stats_by_key(p_id)` | Statystyki przedmiotu po ID |
| `items.get_items()` | Wszystkie przedmioty |
| `items.get_items_by_key(p_id)` | Przedmiot po ID |
| `world.get_landscape_types()` | Wszystkie typy krajobrazu |
| `world.get_landscape_types_by_key(p_id)` | Typ krajobrazu po ID |
| `world.get_map_tiles()` | Wszystkie kafelki mapy |
| `world.get_map_tiles_by_key(p_map_id)` | Kafelki danej mapy |
| `world.get_terrain_types()` | Wszystkie typy terenu |
| `world.get_terrain_types_by_key(p_id)` | Typ terenu po ID |

**Jak implementować narzędzia `automatic_get_api`:**
- Wariant `get_X()` → narzędzie MCP bez parametrów wejściowych
- Wariant `get_X_by_key(p_id)` → narzędzie MCP z jednym parametrem `id` (integer)
- Opis narzędzia powinien jasno wskazywać, że to dane słownikowe
- Możesz grupować pary `get_X` / `get_X_by_key` w jedno narzędzie z opcjonalnym parametrem `id`

---

### Kategoria 2: `get_api`
Funkcje zwracające dane kontekstowe zależne od gracza (co widzi, co wie, jaka jest jego pozycja itd.). Zawsze przyjmują przynajmniej `p_player_id`. Część przyjmuje też `p_other_player_id` jako `text` — może to być liczba całkowita LUB UUID (masked_id).

**Lista funkcji `get_api`:**
| Funkcja | Parametry | Opis |
|---|---|---|
| `attributes.get_player_abilities(p_player_id)` | player_id | Zdolności własnego gracza |
| `attributes.get_player_skills(p_player_id)` | player_id | Umiejętności własnego gracza |
| `attributes.get_player_stats(p_player_id)` | player_id | Statystyki własnego gracza |
| `attributes.get_other_player_abilities(p_player_id, p_other_player_id)` | player_id, other_player_id(text) | Zdolności innego gracza (jeśli znane) |
| `attributes.get_other_player_skills(p_player_id, p_other_player_id)` | player_id, other_player_id(text) | Umiejętności innego gracza (jeśli znane) |
| `attributes.get_other_player_stats(p_player_id, p_other_player_id)` | player_id, other_player_id(text) | Statystyki innego gracza (jeśli znane) |
| `cities.get_player_city(p_player_id)` | player_id | Miasto, w którym stoi gracz |
| `inventory.get_player_inventory(p_player_id)` | player_id | Ekwipunek (plecak) gracza |
| `inventory.get_player_gear_inventory(p_player_id)` | player_id | Gear (wyposażenie) gracza |
| `inventory.get_building_inventory(p_building_id)` | building_id | Ekwipunek budynku |
| `inventory.get_district_inventory(p_district_id)` | district_id | Ekwipunek dzielnicy |
| `inventory.get_other_player_inventory(p_player_id, p_other_player_id)` | player_id, other_player_id(text) | Plecak innego gracza (jeśli znany) |
| `inventory.get_other_player_gear_inventory(p_player_id, p_other_player_id)` | player_id, other_player_id(text) | Gear innego gracza (jeśli znany) |
| `players.get_active_player_profile(p_player_id)` | player_id | Profil aktywnego gracza |
| `players.get_active_player_switch_profiles(p_player_id)` | player_id | Lista postaci do przełączenia (tego samego user_id) |
| `players.get_other_player_profile(p_player_id, p_other_player_id)` | player_id, other_player_id(text) | Profil innego gracza (jeśli znany) |
| `squad.get_active_player_squad(p_player_id)` | player_id | Drużyna gracza |
| `squad.get_active_player_squad_players_profiles(p_player_id)` | player_id | Profile graczy z własnej drużyny |
| `squad.get_other_squad_players_profiles(p_player_id, p_squad_id)` | player_id, squad_id | Profile graczy z obcej drużyny |
| `world.get_player_map(p_player_id)` | player_id | ID mapy gracza |
| `world.get_player_position(p_map_id, p_player_id)` | map_id, player_id | Pozycja gracza na mapie |
| `world.get_player_movement(p_player_id)` | player_id | Aktualna kolejka ruchów gracza |
| `world.get_known_map_tiles(p_map_id, p_player_id)` | map_id, player_id | Znane kafelki mapy (fog of war) |
| `world.get_known_map_region(p_map_id, p_player_id, p_region_type)` | map_id, player_id, region_type | Znane regiony danego typu |
| `world.get_known_map_tiles_resources_on_tile(p_map_id, p_map_tile_x, p_map_tile_y, p_player_id)` | map_id, map_tile_x, map_tile_y, player_id | Zasoby na konkretnym kafelku |
| `world.get_known_players_positions(p_map_id, p_player_id)` | map_id, player_id | Pozycje znanych graczy na mapie |
| `world.get_players_on_tile(p_map_id, p_map_tile_x, p_map_tile_y, p_player_id)` | map_id, map_tile_x, map_tile_y, player_id | Gracze stojący na danym kafelku |

**Jak implementować narzędzia `get_api`:**
- Każda funkcja to osobne narzędzie MCP
- Parametr `p_player_id` jest zawsze wymagany i oznacza **aktywnego gracza** (osoby korzystającej z serwera)
- Parametr `p_other_player_id` przyjmuje `text` — może być ID (int) lub masked UUID — przekazuj as-is
- Wyniki zwracaj jako JSON array (jeden wiersz = jeden obiekt)
- Jeśli wynik jest pusty, zwróć pustą tablicę — nie traktuj tego jako błąd

---

### Kategoria 3: `action_api`
Funkcje wykonujące **akcje gracza** w grze. Są to operacje modyfikujące stan gry. Wszystkie przyjmują `p_player_id` jako pierwszy parametr i zwracają `TABLE(status boolean, message text)`.

Funkcje action_api często nie wykonują akcji natychmiast — mogą kolejkować zadania do tabeli `tasks.tasks`, które są wykonywane asynchronicznie przez scheduler (bazodanowe procedury uruchamiane cyklicznie).

**Lista funkcji `action_api`:**

| Funkcja | Parametry | Opis akcji |
|---|---|---|
| `world.do_player_movement(p_player_id, p_path jsonb)` | player_id, path (JSONB array) | Zlecenie ruchu gracza po ścieżce |
| `world.do_map_tile_exploration(p_player_id, parameters jsonb)` | player_id, parameters (JSONB array) | Eksploracja kafelków mapy |
| `items.do_gather_resources_on_map_tile(p_player_id, parameters jsonb)` | player_id, parameters (JSONB array) | Zbieranie zasobów z kafelka |
| `inventory.do_add_item_to_inventory(p_inventory_container_id, p_item_id, p_quantity)` | inventory_container_id, item_id, quantity | Dodanie przedmiotu do ekwipunku |
| `inventory.do_move_or_swap_item(p_player_id, p_from_slot_id, p_to_slot_id, p_from_inventory_container_id, p_to_inventory_container_id)` | player_id, from_slot_id, to_slot_id, from_container_id, to_container_id | Przeniesienie/zamiana przedmiotów między slotami |
| `players.do_switch_active_player(p_player_id, p_switch_to_player_id)` | player_id, switch_to_player_id | Przełączenie aktywnej postaci |

**Jak implementować narzędzia `action_api`:**
- Każda funkcja to osobne narzędzie MCP z wyraźnie opisaną semantyką akcji
- Wynik zawsze zawiera `status` (boolean) i `message` (text) — przekaż je wprost do klienta
- Jeśli `status = false`, narzędzie powinno zwrócić błąd z treścią `message`
- Akcje z parametrem JSONB (ruch, eksploracja, zbieranie) mają złożoną strukturę — szczegóły poniżej

**Struktura JSONB dla `do_player_movement`:**
```json
[
  { "order": 1, "mapId": 1, "x": 5, "y": 6, "moveCost": 2, "totalMoveCost": 2 },
  { "order": 2, "mapId": 1, "x": 5, "y": 7, "moveCost": 3, "totalMoveCost": 5 }
]
```
Każdy element to jeden krok ruchu. `totalMoveCost` to skumulowany koszt do tego kroku (determinuje czas wykonania w minutach).

**Struktura JSONB dla `do_map_tile_exploration`:**
```json
[
  { "mapId": 1, "x": 5, "y": 6, "explorationLevel": 0 },
  { "mapId": 1, "x": 5, "y": 7, "explorationLevel": 2 }
]
```
`explorationLevel` wpływa na czas eksploracji: `GREATEST(100 * (1 - explorationLevel * 0.1), 0.1)` minut.

**Struktura JSONB dla `do_gather_resources_on_map_tile`:**
```json
[
  { "mapId": 1, "x": 5, "y": 6, "itemId": 3, "gatherAmount": 5 }
]
```
`gatherAmount` to liczba jednostek do zebrania — każda jednostka kosztuje 1 minutę.

---

## Szczegóły techniczne implementacji MCP serwera

### Połączenie z bazą danych
- Używaj PostgreSQL klienta (np. `pg` dla Node.js lub `asyncpg`/`psycopg2` dla Pythona)
- Wszystkie funkcje wywołuj przez `SELECT * FROM schema.function_name(parametry)` lub `CALL schema.procedure_name(parametry)` dla procedur
- Obsługuj pool połączeń

### Wzorzec wywoływania funkcji
```sql
-- Funkcje zwracające SETOF lub TABLE:
SELECT * FROM attributes.get_player_abilities($1);

-- Funkcje zwracające skalary lub void:
SELECT attributes.unlock_player_abilities($1);

-- Procedury (admin schema):
CALL admin.new_player($1, $2, $3);
```

### Obsługa błędów
- Baza używa `util.raise_error()` rzucającego `SQLSTATE = 'P0001'` (wyjątek aplikacyjny)
- Funkcje `action_api` przechwytują te błędy i zwracają `status = false, message = SQLERRM`
- Funkcje `get_api` mogą rzucać wyjątki — obsługuj je po stronie MCP serwera
- Zawsze zwracaj sensowny komunikat błędu

### Typ `p_other_player_id` (text)
Wiele funkcji `get_api` przyjmuje `p_other_player_id text`. Może to być:
- Zwykłe ID gracza jako string, np. `"42"`
- UUID (masked_id) gracza, np. `"550e8400-e29b-41d4-a716-446655440000"`

Baza sama rozwiązuje który to przypadek przez funkcję `players.get_real_player_id()`. Po stronie MCP akceptuj ten parametr jako string i przekazuj bez konwersji.

### Narzędzia pomocnicze (nie eksponuj jako MCP tools)
Następujące funkcje są wewnętrzne — nie twórz dla nich narzędzi MCP:
- `players.get_active_player(p_user_id)` — zwraca player_id aktywnej postaci; użyteczne do bootstrapu sesji
- `players.get_real_player_id(p_other_player_id)` — mapowanie identyfikatorów
- `attributes.unlock_player_abilities(p_player_id)` — wewnętrzna logika odblokowania
- `inventory.get_container_tile()`, `inventory.check_*` — wewnętrzne walidatory
- `tasks.cancel_task()`, `tasks.insert_task()` — wewnętrzne zarządzanie kolejką
- Wszystkie funkcje ze schematu `admin` — operacje administracyjne, nie gracza

---

## Rekomendowana struktura narzędzi MCP

### Grupowanie narzędzi

**Grupa: Dane słownikowe (Reference Data)**
Zgrupuj pary `get_X` / `get_X_by_key` w jedno narzędzie z opcjonalnym parametrem `id`. Np.:
- `get_abilities` — opcjonalne `id`
- `get_skills` — opcjonalne `id`
- `get_stats` — opcjonalne `id`
- `get_roles` — opcjonalne `id`
- `get_terrain_types` — opcjonalne `id`
- `get_landscape_types` — opcjonalne `id`
- `get_building_types` — opcjonalne `id`
- `get_district_types` — opcjonalne `id`
- `get_items` — opcjonalne `id`
- `get_item_stats` — opcjonalne `id`
- `get_inventory_slot_types` — opcjonalne `id`
- `get_buildings` — opcjonalne `city_id`
- `get_cities` — opcjonalne `map_id`
- `get_city_tiles` — opcjonalne `city_id`
- `get_districts` — opcjonalne `map_id`
- `get_map_tiles` — opcjonalne `map_id`

**Grupa: Stan gracza (Player State)**
- `get_player_profile` — profil aktywnej postaci
- `get_player_stats_skills_abilities` — statystyki, umiejętności, zdolności
- `get_player_position` — pozycja na mapie
- `get_player_movement` — aktualna kolejka ruchów
- `get_player_map` — ID mapy gracza
- `get_player_city` — miasto gracza
- `get_player_inventory` — plecak
- `get_player_gear` — wyposażenie (gear)
- `get_player_switch_profiles` — dostępne postacie do przełączenia
- `get_player_squad` — drużyna gracza

**Grupa: Świat (World)**
- `get_known_map_tiles` — znane kafelki (fog of war)
- `get_known_map_region` — znane regiony
- `get_known_map_tiles_resources` — zasoby na kafelku
- `get_known_players_positions` — pozycje znanych graczy
- `get_players_on_tile` — gracze na danym kafelku

**Grupa: Inny gracz (Other Player)**
- `get_other_player_profile` — profil
- `get_other_player_stats_skills_abilities` — statystyki, umiejętności, zdolności
- `get_other_player_inventory` — plecak
- `get_other_player_gear` — gear
- `get_other_squad_players` — gracze z drużyny

**Grupa: Ekwipunek innych (External Inventories)**
- `get_building_inventory` — ekwipunek budynku
- `get_district_inventory` — ekwipunek dzielnicy

**Grupa: Akcje gracza (Player Actions)**
- `action_player_movement` — zlecenie ruchu
- `action_map_tile_exploration` — eksploracja kafelków
- `action_gather_resources` — zbieranie zasobów
- `action_move_or_swap_item` — przenoszenie przedmiotów
- `action_add_item_to_inventory` — dodanie przedmiotu
- `action_switch_active_player` — przełączenie postaci

---

## Uwagi dotyczące systemu knowledge (wiedzy gracza)

Baza implementuje system "fog of war" i wiedzy o innych graczach:
- Gracz widzi tylko kafelki z `knowledge.known_map_tiles`
- Gracz widzi innych graczy tylko jeśli są w `knowledge.known_players_positions`
- Dane innych graczy (profil, statystyki) zwracają `NULL` dla nieznanych pól (nie błąd!)
- `other_player_id` w odpowiedziach to albo prawdziwe ID (jeśli gracz zna profil) albo `masked_id` UUID (jeśli gracz tylko widzi postać, ale jej nie zna)

To zachowanie jest wbudowane w funkcje `get_api` — MCP serwer nie musi tego obsługiwać osobno, po prostu przekaż wyniki jak są.

---

## Przykładowy przepływ sesji

1. Użytkownik loguje się → pobierz `user_id` z sesji
2. Wywołaj `players.get_active_player(user_id)` → uzyskaj `player_id` aktywnej postaci
3. `player_id` jest kontekstem dla wszystkich kolejnych narzędzi MCP
4. Gracz wykonuje akcje → wywołuj odpowiednie `action_api`
5. Gracz odpytuje stan → wywołuj odpowiednie `get_api`
6. Gracz chce zmienić postać → `action_switch_active_player(current_player_id, target_player_id)`

---

## Dodatkowe wskazówki

- **Nazewnictwo parametrów MCP**: używaj camelCase w schemacie JSON narzędzi (np. `playerId`, `mapId`, `fromSlotId`), ale konwertuj na snake_case przy przekazaniu do SQL
- **Paginacja**: funkcje nie mają wbudowanej paginacji — dla `get_map_tiles` (do 3600 rekordów przy mapie 60x60) rozważ zwracanie danych w chunках lub ograniczenie po stronie klienta
- **Typy danych**: PostgreSQL `integer` → JSON `number`, `character varying` → JSON `string`, `boolean` → JSON `boolean`, `jsonb` → JSON `object/array`, `uuid` → JSON `string`
- **Timestampy**: zwracaj jako ISO 8601 string
- **NULL**: zwracaj jako JSON `null`
