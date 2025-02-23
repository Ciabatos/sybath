import { atom } from "jotai"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"

export const mapTerrainTypesAtom = atom([] as TMapTerrainTypes[])

export const mapTilesAtom = atom<{
  data: TMapTiles[] | null
  isLoading: boolean
  error: Error | null
}>({
  data: null,
  isLoading: true,
  error: null,
})
