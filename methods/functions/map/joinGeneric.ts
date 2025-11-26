import { produce } from "immer";
"use server"
import { auth } from "@/auth"
import CityWrapper from "@/components/city/CityWrapper"
import { joinCity } from "@/methods/functions/map/joinCity"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getSkillsServer"
import { getPlayerInventoryServer } from "@/methods/server-fetchers/items/getPlayerInventoryServer"
import { getMapBuildingsByKeyServer } from "@/methods/server-fetchers/map/getBuildingsByKeyServer"
import { getMapCityTilesByKeyServer } from "@/methods/server-fetchers/map/getCityTilesByKeyServer"
import { getMapLandscapeTypesServer } from "@/methods/server-fetchers/map/getLandscapeTypesServer"
import { getMapTerrainTypesServer } from "@/methods/server-fetchers/map/getTerrainTypesServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { SWRProvider } from "@/providers/swr-provider"
import styles from "./page.module.css"

type RecordById<T> = Record<string, T>;

// Typ dla pojedynczego "łączenia": mapa metadanych i nazwa klucza w dynamicData
interface MetadataJoin<TMeta> {
  metaData: RecordById<TMeta>;
  foreignKey: string; // pole w dynamicData wskazujące na ID w metaData
  joinOn?: string; // opcjonalnie, nazwa pola pod którą zapisujemy meta w output
}


export function joinWithMultipleMetadata<TDynamic extends Record<string, any>>(
  dynamicData: RecordById<TDynamic>,
  metadataJoins: MetadataJoin<any>[],
  options?: {
    oldDataToUpdate?: RecordById<any>;
  }
): RecordById<any> {
  const { oldDataToUpdate } = options ?? {};

  function createOrUpdate(item: TDynamic) {
    const newItem: any = { ...item };

    metadataJoins.forEach(({ metaData, foreignKey, joinOn }) => {
      const metaKey = item[foreignKey];
      const meta = metaKey != null ? metaData[metaKey] : undefined;
      newItem[joinOn ?? foreignKey] = meta;
    });

    return newItem;
  }

  const entries = Object.entries(dynamicData);

  if (oldDataToUpdate) {
    return produce(oldDataToUpdate, (draft) => {
      entries.forEach(([key, data]) => {
        if (draft[key]) {
          draft[key] = createOrUpdate(data);
        }
      });
    });
  } else {
    return Object.fromEntries(entries.map(([key, data]) => [key, createOrUpdate(data)]));
  }
}

  const [cityTiles, terrainTypes, landscapeTypes, buildings, skills, abilities, playerIventory, playerSkills, playerAbilities] = await Promise.all([
    getMapCityTilesByKeyServer({ cityId }),
    getMapTerrainTypesServer(),
    getMapLandscapeTypesServer(),
    getMapBuildingsByKeyServer({ id: cityId }),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerInventoryServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
  ])

const joinedTiles = joinWithMultipleMetadata(cityTiles.byKey, 
  [
  { metaData: terrainTypes.byKey, foreignKey: "terrainTypeId", joinOn: "terrain" },
  { metaData: landscapeTypes.byKey, foreignKey: "landscapeTypeId", joinOn: "landscape" },
  { metaData: buildings.byKey, foreignKey: "tileKey", joinOn: "building" },
  ]
);