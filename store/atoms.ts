import { atom } from "jotai"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TClickedTile } from "@/components/MapTile"

export const mapTilesAtom = atom<TMapTiles[]>([])
export const joinedMapTilesAtom = atom<Record<string, TjoinedMapTile>>({})
export const clickedTileAtom = atom<TClickedTile | null>(null)
