import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { atom } from "jotai"

export const citiesAtom = atom<TCitiesCitiesRecordByMapTileXMapTileY>({})
