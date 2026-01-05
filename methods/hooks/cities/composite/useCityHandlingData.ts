import { useFetchBuildingsBuildingsByKey } from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingsByKey"
import { useFetchBuildingsBuildingTypes } from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingTypes"
import { useCityId } from "@/methods/hooks/cities/composite/useCityId"
import { useFetchCitiesCityTilesByKey } from "@/methods/hooks/cities/core/useFetchCitiesCityTilesByKey"
import { useFetchWorldLandscapeTypes } from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import { useFetchWorldTerrainTypes } from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"

export function useCityHandlingData() {
  const { cityId } = useCityId()
  const { cityTiles } = useFetchCitiesCityTilesByKey({ cityId })
  const { buildings } = useFetchBuildingsBuildingsByKey({ cityId })
  const { terrainTypes } = useFetchWorldTerrainTypes()
  const { landscapeTypes } = useFetchWorldLandscapeTypes()
  const { buildingTypes } = useFetchBuildingsBuildingTypes()

  return { cityTiles, cityId, terrainTypes, landscapeTypes, buildings, buildingTypes }
}
