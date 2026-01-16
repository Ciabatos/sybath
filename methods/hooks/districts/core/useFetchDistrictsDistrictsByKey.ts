// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TDistrictsDistrictsRecordByMapTileXMapTileY, TDistrictsDistricts, TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictsDistrictsByKey( params: TDistrictsDistrictsParams ) {
  const setDistrictsDistricts = useSetAtom(districtsAtom)
  
  const { data } = useSWR<TDistrictsDistricts[]>(`/api/districts/districts/${params.mapId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const districts = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TDistrictsDistrictsRecordByMapTileXMapTileY
      setDistrictsDistricts(districts)
    }
  }, [data, setDistrictsDistricts])
}
