import { useFetchBuildingsBuildingsByKey } from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingsByKey"
import { useFetchBuildingsBuildingTypes } from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingTypes"
import { useCityId } from "@/methods/hooks/cities/composite/useCityId"
import { useFetchCitiesCityTilesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCityTilesByKey"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"
import { buildingsAtom, buildingTypesAtom, cityTilesAtom, landscapeTypesAtom, terrainTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useCityHandlingData() {
  const { cityId } = useCityId()

  useFetchCitiesCityTilesByKey({ cityId })
  const cityTiles = useAtomValue(cityTilesAtom)

  useFetchBuildingsBuildingsByKey({ cityId })
  const buildings = useAtomValue(buildingsAtom)

  useFetchWorldTerrainTypes()
  const terrainTypes = useAtomValue(terrainTypesAtom)

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  useFetchBuildingsBuildingTypes()
  const buildingTypes = useAtomValue(buildingTypesAtom)

  return { cityTiles, cityId, terrainTypes, landscapeTypes, buildings, buildingTypes }
}
