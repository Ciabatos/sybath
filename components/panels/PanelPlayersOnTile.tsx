"use client"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import usePlayersOnTile from "@/methods/hooks/world/composite/usePlayersOnTile"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { X } from "lucide-react"
import styles from "./styles/PanelPlayersOnTile.module.css"

export default function PanelPlayersOnTile() {
  const { resetModalTopCeneter } = useModalTopCenter()
  const { openModalLeftTopBar } = useModalLeftTopBar()

  const { clickedTile } = useMapTileActions()
  if (!clickedTile) return null

  const { playersOnTile } = usePlayersOnTile(clickedTile.mapTiles.x, clickedTile.mapTiles.y)
  if (!playersOnTile) return null

  const handleClickPlayerPortrait = () => {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPanel)
  }

  const onClose = () => {
    resetModalTopCeneter()
  }

  return (
    <>
      <div className={styles.panel}>
        <div>Lista Playerów</div>
        <Button
          onClick={onClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <X className={styles.closeIcon} />
        </Button>
        {Object.entries(playersOnTile).map(([key, otherPlayer]) => (
          <div key={key}>
            <div>{otherPlayer.name}</div>
            <div>{otherPlayer.secondName}</div>
            <div>{otherPlayer.nickname}</div>
            <Button
              onClick={handleClickPlayerPortrait}
              className={styles.heroButton}
            >
              <PlayerPortrait imagePortrait={otherPlayer.imagePortrait} />
            </Button>
          </div>
        ))}
      </div>
    </>
  )
}
