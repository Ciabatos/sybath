import type { TTradeSlot } from "@/components/trade/TradeSlot"

/**
 * Mocki dla panelu Trade.
 * Hook useTrade daje realne dane tylko dla slotów (side, itemId, quantity, nazwa, opis, ikona).
 * Wszystko, co dotyczy kontrahenta, statusu, wyceny i akcji, jest tymczasowo zasymulowane.
 */

export const MOCK_TRADE = {
  id: "TR-2049",
  partnerName: "Boromir Złotouchy",
  partnerTitle: "Kupiec z Złotego Brzegu",
  partnerIcon: "HandCoinsIcon",
  partnerLevel: 24,
  partnerStanding: 812,
  partnerMood: "Uśmiechnięty",
  status: "Twoja kolej",
  statusHint: "Partner czeka na twoją odpowiedź",
  expiresIn: "02:14",
  feePercent: 5,
  emptyHint: "Przeciągnij przedmiot z ekwipunku, aby złożyć ofertę",
  detailHint: "Kliknij przedmiot w ofercie, aby podejrzeć jego szczegóły",
} as const

export type TSideTotal = {
  slotsUsed: number
  slotsTotal: number
  units: number
  value: number
}

/** Wycena przedmiotów — w prawdziwej wersji zostanie podmieniona na wartość z API. */
const VALUE_TABLE: Record<string, number> = {
  Sword: 145,
  Armour: 220,
  Shield: 95,
  Boots: 70,
  Ring: 260,
  Necklace: 190,
  Belt: 60,
  Cloak: 120,
  Helmet: 165,
  Anvil: 310,
  Axe: 85,
  Wood: 12,
  Stone: 8,
  Gold: 999,
}

const RARITY_LABELS = ["Pospolity", "Niezwykły", "Rzadki", "Epicki", "Legendarny"] as const

function hashName(name: string) {
  let hash = 0
  for (let index = 0; index < name.length; index += 1) {
    hash = (hash * 31 + name.charCodeAt(index)) % 100_000
  }
  return hash
}

export function mockItemValue(item: TTradeSlot) {
  if (!item?.itemId) return 0
  const base = VALUE_TABLE[item.name] ?? 40 + (hashName(item.name ?? "") % 160)
  return base * Math.max(1, item.quantity || 1)
}

export function mockRarity(item: TTradeSlot) {
  const tier = (hashName(`${item?.name ?? ""}-${item?.itemId ?? 0}`) + (item?.slotId ?? 0)) % RARITY_LABELS.length
  return { label: RARITY_LABELS[tier], tone: tier }
}

export function mockSideTotal(inventory: TTradeSlot[]): TSideTotal {
  const filled = inventory.filter((item) => item.itemId)

  return {
    slotsUsed: filled.length,
    slotsTotal: inventory.length,
    units: filled.reduce((sum, item) => sum + Math.max(1, item.quantity || 1), 0),
    value: filled.reduce((sum, item) => sum + mockItemValue(item), 0),
  }
}

