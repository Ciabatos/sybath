import { atom } from "jotai"

/**
 * Warstwa szczegółowa kafelka. Baza (teren, miasta, obrys regionów, marker
 * gracza, plan ruchu) jest zawsze włączona — przełączamy tylko to, co na niej
 * leży.
 *
 * Wybór jest WYŁĄCZNY: tylko jedna warstwa naraz, inaczej kafelek pokazywałby
 * dwie konkurujące zestawy ikon.
 */
export const MAP_LAYERS = {
  none: "none",
  resources: "resources",
  heroes: "heroes",
} as const

export type TMapLayer = (typeof MAP_LAYERS)[keyof typeof MAP_LAYERS]

export const activeLayerAtom = atom<{ layer: TMapLayer }>({ layer: MAP_LAYERS.resources })