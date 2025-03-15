"use client"

import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"
import type { TjoinedMapTile } from "@/methods/functions/joinMapTilesServer"
import type { TClickedTile } from "@/methods/hooks/useMapTileClick"
import { TMovmentPath } from "@/methods/hooks/useMapTilesPath"
import { EMapTilesActionStatus } from "@/types/enumeration/MapTilesActionStatusEnum"
import { atom } from "jotai"

export const mapTilesAtom = atom<TMapTiles[]>([])
export const joinedMapTilesAtom = atom<Record<string, TjoinedMapTile>>({})
export const mapTilesPlayerPostionAtom = atom<Record<string, TMapsFieldsPlayerPosition>>({})
export const clickedTileAtom = atom<TClickedTile>({ x: 1, y: 1 })
export const mapTilesActionStatusAtom = atom<EMapTilesActionStatus>(EMapTilesActionStatus.Inactive)
export const mapTilesMovmentPathAtom = atom<TMovmentPath[]>([])
export const mapTilesGuardAreaAtom = atom<TjoinedMapTile[]>([])
