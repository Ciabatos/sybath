import { atom } from "jotai"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"

export const mapTilesAtom = atom<TMapTiles[]>([])
