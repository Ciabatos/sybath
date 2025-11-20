# 🎮 Sybath - Masywnie Multiplayer Online RPG

Projekt zaawansowanej gry online (MMO) napisanej w **Next.js** z architekturą **database-driven** i automatycznym generowaniem backendu za pomocą **PlopJS**.

## 🎯 O Projekcie

**Sybath** to gra strategiczna MMO łącząca elementy rpg, city-buildingu, zarządzania zasobami i eksploracji mapy świata.

---

## 🏗️ Architektura

### Database-Driven Development

Cała logika biznesowa jest oparta na bazie danych PostgreSQL:

```
Definicja w PostgreSQL
    ↓
PlopJS Generator
    ↓
Automatyczne tworzenie:
├── TypeScript schematów typów
├── API Routes (GET/POST)
├── React Hooks (useFetch*)
├── Server-side Fetchers
└── Atom State (Jotai)
```

### Struktura Projektu

```
src/
├── db/postgresMainDatabase/schemas/
│      ├── map/          (świat, miasta, dystrykt)
│      ├── players/      (gracze, umiejętności)
│      ├── items/        (inwentarz, przedmioty)
│      └── attributes/   (atrybuty, zdolności)
│   
│
├── app/api/
│   ├── [schema]/[table]/          (GET - wszystkie rekordy)
│   ├── [schema]/[table]/[id]/      (GET - po ID)
│   └── [schema]/rpc/[method]/      (Wywoływanie procedur)
│
├── methods/
│   ├── hooks/            (React useFetch* - client-side)
│   ├── server-fetchers/  (Server-side data fetching)
│   └── actions/          (Server actions - mutacje)
│
├── components/
│   ├── map/              (komponenty mapy)
│   ├── city/             (komponenty miasta)
│   └── portals/modals/   (modale UI)
│
└── store/
    └── atoms.ts          (Jotai atoms - state management)
```

---

## 🔧 Technologia

### Frontend Stack

| Technologia | Wersja | Użycie |
|-------------|--------|--------|
| **Next.js** | 14+ | Framework, App Router |
| **React** | 18+ | Component model |
| **TypeScript** | Latest | Type safety |
| **Jotai** | Latest | State management |
| **SWR** | Latest | Data fetching |
| **TailwindCSS** | Latest | Styling |
| **shadcn/ui** | Latest | UI Components |

### Backend Stack

| Technologia | Wersja | Użycie |
|-------------|--------|--------|
| **Next.js API Routes** | 14+ | Serverless backend |
| **PostgreSQL** | 17 | Relacyjna baza |
| **PlopJS** | Latest | Code generation |
| **Auth.js** | Latest | Authentication |
| **Zod** | Latest | Schema validation |

---

## ✨ Kluczowe Funkcjonalności

### 🗺️ System Mapy
- Proceduralne generowanie terenu
- Dynamiczne załadowanie danych
- Real-time pozycja gracza
- Eksploracja świata

### 🏘️ Miasta i Dystrykt
- Sub-mapy dla miast
- Zarządzanie budynkami
- Strefa produkcji (dystrykt)
- System ról (Owner, Worker)

### 📦 System Inwentarza
- Wielowarstwowy system magazynowania
- Inwentarz gracza, budynku, dystryku
- Slot-based storage (grid)
- Automatyczne sortowanie

### 👤 System Postaci
- Umiejętności (Skills)
- Zdolności (Abilities)
- System progresji
- Atrybuty charakteru

### ⚔️ Walka (w trakcie)
- Inspiracja: Slay the Spire
- System akcji turowych
- Karty akcji (Attack, Parry, Riposte)
- Replay systemu rund

---

## 🚀 Automatyzacja Kodu

### PlopJS Generatory

Jeden wybór z CLI generuje 8+ w pełni funkcjonalnych plików:

```bash
plop "Get Data From Table"
  ↓
```

| Plik | Typ | Opis |
|------|-----|------|
| `db/postgresMainDatabase/schemas/[schema]/[table].ts` | TypeScript | Typ i fetch funkcja |
| `app/api/[schema]/[table]/route.ts` | API Route | GET wszystkie |
| `app/api/[schema]/[table]/[id]/route.ts` | API Route | GET po ID |
| `methods/hooks/[schema]/useFetch[Table].ts` | React Hook | Client-side fetch |
| `methods/hooks/[schema]/useFetch[Table]ByKey.ts` | React Hook | Fetch z cache |
| `methods/server-fetchers/[schema]/get[Table]Server.ts` | Server Function | Server-side fetch |
| `methods/server-fetchers/[schema]/get[Table]ByKeyServer.ts` | Server Function | By Key server |
| `store/atoms.ts` | Atom Store | State management |

### Redukcja Boilerplate

| Metoda | Ilość Kodu | Redukcja |
|--------|-----------|----------|
| Tradycyjny | ~500 linii | - |
| Z PlopJS | ~50 linii | **90%** |
| **Zysk** | **450 linii** | **Per funkcja** |

---

## 🔐 Bezpieczeństwo

| Warstwa | Mechanizm | Status |
|---------|-----------|--------|
| Database | PostgreSQL RLS | ✅ |
| Auth | Auth.js sessions | ✅ |
| Validation | Zod schemas | ✅ |
| Types | TypeScript end-to-end | ✅ |
| API | CSRF protection | ✅ |

---

## 📊 Wzorce Programowania

### 1️⃣ Server Actions z Type Safety

```typescript
export async function addItemToInventoryAction({ 
  playerId, 
  item_id, 
  quantity 
}: TAddItemToInventory) {
  // Direct database mutation
}
```

### 2️⃣ Destrukturyzacja w Funkcjach

```typescript
// Jawnie pokazuje używane pola, zachowując elastyczność typu
function addItemToInventory({ 
  playerId, 
  item_id, 
  quantity 
}: TAddItemToInventory)
```

### 3️⃣ Atom-based State Management

```typescript
export const districtAtom = atom<TDistrictRecordById>({})
export const selectedHeroAtom = atom<number | null>(null)
```

---

## 💼 Portfolio Value

### Demonstrowane Umiejętności

| Umiejętność | Level | Opis |
|------------|-------|------|
| **Full-Stack TypeScript** | Expert | End-to-end type safety |
| **Database Design** | Advanced | PostgreSQL, RLS, procedures |
| **Code Generation** | Advanced | PlopJS automation |
| **Architecture** | Senior | Scalable, maintainable |
| **Performance** | Advanced | ETag caching, SWR |
| **Security** | Advanced | RLS, validation, auth |
| **MMO Architecture** | Intermediate | Game systems design |

---

## 🛠️ Tech Stack Overview

```
┌─────────────────────────────────────────────────────┐
│                    Frontend Layer                     │
│  React 18+ │ TypeScript │ Jotai │ SWR │ TailwindCSS │
└──────────────────────┬──────────────────────────────┘
                       │
                  API Layer
                       │
┌──────────────────────┴──────────────────────────────┐
│                    Backend Layer                     │
│  Next.js API Routes │ Auth.js │ Zod Validation     │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────┴──────────────────────────────┐
│                  Database Layer                      │
│    PostgreSQL 17 │ RLS │ Procedures │ PL/pgSQL      │
└─────────────────────────────────────────────────────┘
```

---

## 🎓 Kluczowe Learningi

| Temat | Insight |
|-------|---------|
| Database-driven dev | Zmniejsza boilerplate o 90% |
| Code generation | Zmienia produktywność |
| Type safety | Od bazy do UI - game-changer |
| PostgreSQL logic | Lepsze niż client-side |
| Atom state mgmt | Elegancki i efektywny |

---

## 📝 Quick Start

```bash
# Instalacja zależności
npm install

# Uruchomienie development
npm run dev

# Code generation
npx run plop
```

## 📞 O Projekcie

Projekt demonstruje zaawansowaną wiedzę z zakresu:

- ✅ Full-Stack TypeScript Development
- ✅ Database Architecture & Optimization
- ✅ Code Generation & Automation (PlopJS)
- ✅ MMO Game Architecture & Systems
- ✅ Production-Ready Code Quality
- ✅ Performance Optimization
- ✅ Security Best Practices


