import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedMapTileById } from "@/methods/functions/joinMapTiles"
import { useJoinMapTiles } from "@/methods/hooks/mapTiles/useJoinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useHydrateAtoms } from "jotai/utils"

interface Props {
  joinedMapTiles: TJoinedMapTileById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useMapTilesBuildOnClient({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  useHydrateAtoms([[joinedMapTilesAtom, joinedMapTiles]])

  const newJoinedMapTilesOnClient = useAtomValue(joinedMapTilesAtom)

  useJoinMapTiles(terrainTypes, landscapeTypes)

  return {
    newJoinedMapTilesOnClient,
  }
}
