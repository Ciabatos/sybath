"use client"
import { useSession } from "next-auth/react"
import useSWR from "swr"
import MapTile from "./MapTile"
import useFetchMapTiles from "@/functions/hooks/useFetchMapTiles"
import type { TjoinedMapTile } from "@/functions/services/map/mapTilesServerData"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import { useAtomValue } from "jotai"
import { mapTilesAtom } from "@/store/atoms"

interface Props {
  joinedMapTiles: Record<string, TjoinedMapTile>
  terrainTypesById: Record<string, TMapTerrainTypes>
}

export default function MapTilesClient({ joinedMapTiles, terrainTypesById }: Props) {
  // const session = useSession()
  // const { data, error, isLoading } = useSWR("/api/users")

  useFetchMapTiles()
  const mapTiles = useAtomValue(mapTilesAtom)
  console.log(mapTiles, "mapTiles")

  // if (!session.data?.user?.email) {
  //   return <div>Sing In !</div>
  // }
  // if (isLoading) {
  //   return <div>Loading...</div>
  // }
  // if (error) {
  //   return <div>Error: {error.message}</div>
  // }

  return (
    <>
      {Object.entries(joinedMapTiles).map(([key, tile]) => (
        <MapTile
          key={key}
          tile={tile}
        />
      ))}
    </>
  )
}
