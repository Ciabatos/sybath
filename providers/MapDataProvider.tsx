"use client"
import useFetchMapTiles from "@/functions/hooks/useFetchMapTiles"

export const MapDataProvider = ({ children }: { children: React.ReactNode }) => {
  useFetchMapTiles()

  return <>{children}</>
}
