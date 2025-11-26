/* eslint-disable @typescript-eslint/no-explicit-any */

import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/getAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/getSkillsServer"
import { getPlayerInventoryServer } from "@/methods/server-fetchers/items/getPlayerInventoryServer"
import { getMapBuildingsByKeyServer } from "@/methods/server-fetchers/map/getBuildingsByKeyServer"
import { getMapCityTilesByKeyServer } from "@/methods/server-fetchers/map/getCityTilesByKeyServer"
import { getMapLandscapeTypesServer } from "@/methods/server-fetchers/map/getLandscapeTypesServer"
import { getMapTerrainTypesServer } from "@/methods/server-fetchers/map/getTerrainTypesServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/players/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/players/getPlayerSkillsServer"
import { produce } from "immer"

type RecordById<T> = Record<string, T>

// Typ dla pojedynczego "łączenia": mapa metadanych i nazwa klucza w dynamicData
interface MetadataJoin<TMeta> {
  metaData: RecordById<TMeta>
  foreignKey: string // pole w dynamicData wskazujące na ID w metaData
  joinOn?: string // opcjonalnie, nazwa pola pod którą zapisujemy meta w output
}

export function joinWithMultipleMetadata<TDynamic extends Record<string, any>>(
  dynamicData: RecordById<TDynamic>,
  metadataJoins: MetadataJoin<any>[],
  options?: {
    oldDataToUpdate?: RecordById<any>
  },
): RecordById<any> {
  const { oldDataToUpdate } = options ?? {}

  function createOrUpdate(item: TDynamic) {
    const newItem: any = { ...item }

    metadataJoins.forEach(({ metaData, foreignKey, joinOn }) => {
      const metaKey = item[foreignKey]
      const meta = metaKey != null ? metaData[metaKey] : undefined
      newItem[joinOn ?? foreignKey] = meta
    })

    return newItem
  }

  const entries = Object.entries(dynamicData)

  if (oldDataToUpdate) {
    return produce(oldDataToUpdate, (draft) => {
      entries.forEach(([key, data]) => {
        if (draft[key]) {
          draft[key] = createOrUpdate(data)
        }
      })
    })
  } else {
    return Object.fromEntries(entries.map(([key, data]) => [key, createOrUpdate(data)]))
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

const joinedTiles = joinWithMultipleMetadata(cityTiles.byKey, [
  { metaData: terrainTypes.byKey, foreignKey: "terrainTypeId", joinOn: "terrain" },
  { metaData: landscapeTypes.byKey, foreignKey: "landscapeTypeId", joinOn: "landscape" },
  { metaData: buildings.byKey, foreignKey: "tileKey", joinOn: "building" },
])

type JoinConfig<T> = {
  data: Record<string, any>
  key: keyof T | ((item: T) => string)
  optional?: boolean
}

export function joinData<TMain, TResult = any>(
  main: Record<string, TMain>,
  joins: JoinConfig<TMain>[],
  transform: (item: TMain, joined: any[]) => TResult,
  oldData?: Record<string, TResult>,
): Record<string, TResult> {
  function process(item: TMain): TResult {
    const joined = joins.map(({ data, key, optional }) => {
      const k = typeof key === "function" ? key(item) : item[key]
      return data[k as string]
    })
    return transform(item, joined)
  }

  const entries = Object.entries(main)

  if (oldData) {
    return produce(oldData, (draft) => {
      entries.forEach(([k, item]) => {
        if (draft[k]) draft[k] = process(item)
      })
    })
  }

  return Object.fromEntries(entries.map(([k, item]) => [k, process(item)]))
}

////////////////////////
SELECT
  kcu.table_name AS main_table,
  kcu.column_name AS main_column,
  ccu.table_name AS foreign_table,
  ccu.column_name AS foreign_column
FROM
  information_schema.table_constraints AS tc
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE
  tc.constraint_type = 'FOREIGN KEY'
  AND kcu.table_name = 'cities'; -- np. tabela główna

  /////////////////

type ForeignKeyInfo = {
  mainColumn: string
  foreignTable: string
  foreignColumn: string
}

const foreignKeys: ForeignKeyInfo[] = await getForeignKeysFromDB("cities")

for (const fk of foreignKeys) {
  joinMasterSlave(cities, {
    master: {
      object: foreignData[fk.foreignTable],
      key: fk.mainColumn as keyof TCity,
      foreignKey: fk.foreignColumn,
      output: fk.foreignTable
    }
  })
}