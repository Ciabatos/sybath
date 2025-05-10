import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedMapTile } from "@/methods/functions/joinMapTiles"
import { useFetchMapTiles } from "@/methods/hooks/mapTiles/useFetchMapTiles"
import { useFetchPlayerVisibleMapData } from "@/methods/hooks/mapTiles/useFetchPlayerVisibleMapData"
import { useJoinMapTiles } from "@/methods/hooks/mapTiles/useJoinMapTiles"
import { joinedMapTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useHydrateAtoms } from "jotai/utils"

interface Props {
  joinedMapTiles: Record<string, TJoinedMapTile>
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useMapTilesBuildOnClient({ joinedMapTiles, terrainTypes, landscapeTypes }: Props) {
  useHydrateAtoms([[joinedMapTilesAtom, joinedMapTiles]])

  const mapTilesBuildOnClient = useAtomValue(joinedMapTilesAtom)

  useFetchMapTiles()
  useFetchPlayerVisibleMapData()
  useJoinMapTiles(terrainTypes, landscapeTypes)

  return {
    mapTilesBuildOnClient,
  }
}
