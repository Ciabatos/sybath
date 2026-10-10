import { TMapTileResource } from "@/methods/hooks/world/composite/useMapTileDetail"
import { atom } from "jotai"

/**
 * Zasób wybrany do zebrania.
 *
 * `GatherResource` jest osobnym panelem w `ModalTopCenter`, więc nie dostanie
 * zasobu przez prop — musi dzielić stan z `MapTileDetail`.
 *
 * `null` po zamknięciu panelu jest ważne: bez tego otwarcie panelu na innym
 * kafelku pokazałoby poprzedni zasób.
 */
export const gatherResourceAtom = atom<TMapTileResource | null>(null)
