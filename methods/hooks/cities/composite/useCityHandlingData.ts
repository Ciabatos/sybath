import {
  useBuildingsBuildingsState,
  useFetchBuildingsBuildingsByKey,
} from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingsByKey"
import {
  useBuildingsBuildingTypesState,
  useFetchBuildingsBuildingTypes,
} from "@/methods/hooks/buildings/core/useFetchBuildingsBuildingTypes"
import { useCityId } from "@/methods/hooks/cities/composite/useCityId"
import {
  useCitiesCityTilesState,
  useFetchCitiesCityTilesByKey,
} from "@/methods/hooks/cities/core/useFetchCitiesCityTilesByKey"
import {
  useFetchWorldLandscapeTypes,
  useWorldLandscapeTypesState,
} from "@/methods/hooks/world/core/useFetchWorldLandscapeTypes"
import {
  useFetchWorldTerrainTypes,
  useWorldTerrainTypesState,
} from "@/methods/hooks/world/core/useFetchWorldTerrainTypes"

export function useCityHandlingData() {
  const { cityId } = useCityId()

  useFetchCitiesCityTilesByKey({ cityId })
  const cityTiles = useCitiesCityTilesState()

  useFetchBuildingsBuildingsByKey({ cityId })
  const buildings = useBuildingsBuildingsState()

  useFetchWorldTerrainTypes()
  const terrainTypes = useWorldTerrainTypesState()

  useFetchWorldLandscapeTypes()
  const landscapeTypes = useWorldLandscapeTypesState()

  useFetchBuildingsBuildingTypes()
  const buildingTypes = useBuildingsBuildingTypesState()

  return { cityTiles, cityId, terrainTypes, landscapeTypes, buildings, buildingTypes }
}
