"use client"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import usePlayersOnTile from "@/methods/hooks/world/composite/usePlayersOnTile"
import styles from "./styles/PanelPlayersOnTile.module.css"

export default function PanelPlayersOnTile() {
  const { clickedTile } = useMapTileActions()
  if (!clickedTile) return null

  const { playersOnTile } = usePlayersOnTile(clickedTile.mapTiles.x, clickedTile.mapTiles.y)
  if (!playersOnTile) return null

  return (
    <>
      <div className={styles.panel}>
        <div>Lista Playerów</div>
        {Object.entries(playersOnTile).map(([key, otherPlayer]) => (
          <div key={key}>
            <div>{otherPlayer.name}</div>
            <div>{otherPlayer.secondName}</div>
            <div>{otherPlayer.nickname}</div>
            <div>{otherPlayer.imagePortrait}</div>
          </div>
        ))}
      </div>
    </>
  )
}
