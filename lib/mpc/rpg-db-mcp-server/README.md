# rpg-db-mcp-server

MCP server dla bazy danych RPG (PostgreSQL).  
Udostępnia **4 narzędzia** do dynamicznego odkrywania schematu — bez zakodowanych na sztywno nazw tabel czy funkcji.

---

## Narzędzia

| Narzędzie       | Opis                                                   |
| --------------- | ------------------------------------------------------ |
| `get_schema`    | Pełny schemat: tabele + funkcje API w jednym wywołaniu |
| `get_tables`    | Tabele z kolumnami; opcjonalny filtr `schema`          |
| `get_functions` | Funkcje API; opcjonalne filtry `api_type` i `schema`   |

### Typy funkcji API (`api_type`)

| Wartość             | Opis                                                                    |
| ------------------- | ----------------------------------------------------------------------- |
| `automatic_get_api` | Dane słownikowe (typy terenu, przedmioty itp.) — bez kontekstu gracza   |
| `get_api`           | Dane kontekstowe gracza z uwzględnieniem fog-of-war                     |
| `action_api`        | Akcje gracza modyfikujące stan gry; zawsze zwracają `(status, message)` |

---

## Instalacja i uruchomienie

### 1. Wymagania

- Node.js 18+
- Dostęp do bazy PostgreSQL z załadowaną bazą RPG

### 2. Instalacja zależności

```bash
npm install
npm run build
```

### 3. Konfiguracja połączenia z bazą

Ustaw zmienne środowiskowe (lub `DATABASE_URL`):

```bash
# Opcja A — connection string
export DATABASE_URL="postgresql://user:password@localhost:5432/rpg"

# Opcja B — osobne zmienne
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=rpg
export DB_USER=postgres
export DB_PASSWORD=secret
```

### 4. Uruchomienie

```bash
# stdio (domyślny — do integracji z Claude Desktop / MCP clients)
npm start

# HTTP (do testowania przez curl / zdalnego dostępu)
TRANSPORT=http PORT=3000 npm start
```

---

## Integracja z Claude Desktop

Dodaj do `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "rpg-db": {
      "command": "node",
      "args": ["/ścieżka/do/rpg-db-mcp-server/dist/index.js"],
      "env": {
        "DATABASE_URL": "postgresql://user:password@localhost:5432/rpg"
      }
    }
  }
}
```

---

## Struktura projektu

```
rpg-db-mcp-server/
├── src/
│   ├── index.ts           # Entry point, konfiguracja transportu
│   ├── types.ts           # Interfejsy TypeScript
│   ├── constants.ts       # Zapytania SQL i stałe konfiguracyjne
│   ├── services/
│   │   └── db.ts          # Pool PostgreSQL + query helpers
│   └── tools/
│       └── schema.ts      # Rejestracja narzędzi MCP
├── dist/                  # Skompilowany JavaScript
├── package.json
└── tsconfig.json
```

---

## Zapytania SQL używane wewnętrznie

### Tabele (`SQL_GET_TABLES`)

Odpytuje `information_schema.tables` i `information_schema.columns`.  
Wyklucza schematy: `pg_catalog`, `information_schema`, `admin`, `util`.

### Funkcje (`SQL_GET_FUNCTIONS`)

Odpytuje `pg_proc` + `pg_namespace`, filtrując po `obj_description()` — wyłącznie funkcje z komentarzem
`automatic_get_api`, `get_api` lub `action_api`.

---

## Przykładowe wywołania (HTTP)

```bash
# get_schema — pełny schemat
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get_schema","arguments":{"response_format":"markdown"}}}'

# get_tables — tylko schemat world
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_tables","arguments":{"schema":"world"}}}'

# get_functions — tylko akcje gracza
curl -X POST http://localhost:3000/mcp \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"get_functions","arguments":{"api_type":"action_api"}}}'
```
