import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TJoinedCityTilesById } from "@/methods/functions/joinCityTiles"
import { useJoinCityTiles } from "@/methods/hooks/cityTIles/useJoinCityTiles"
import { joinedCityTilesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { useHydrateAtoms } from "jotai/utils"

interface Props {
  cityId: number
  joinedCityTiles: TJoinedCityTilesById
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
}

export function useCityTilesBuildOnClient({ cityId, joinedCityTiles, terrainTypes, landscapeTypes }: Props) {
  useHydrateAtoms([[joinedCityTilesAtom, joinedCityTiles]])

  const newJoinedCityTilesOnClient = useAtomValue(joinedCityTilesAtom)

  useJoinCityTiles(cityId, terrainTypes, landscapeTypes)

  return {
    newJoinedCityTilesOnClient,
  }
}
