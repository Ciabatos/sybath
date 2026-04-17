"use client"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { useSetOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import usePlayersOnTile from "@/methods/hooks/world/composite/usePlayersOnTile"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { X } from "lucide-react"
import styles from "./styles/PlayersOnTile.module.css"

export default function PlayersOnTile() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { openModalRightCenter } = useModalRightCenter()
  const setOtherPlayerId = useSetOtherPlayerId()

  const { clickedMapTile } = useMapTileActions()
  if (!clickedMapTile) return null

  const { playersOnTile } = usePlayersOnTile(clickedMapTile.mapTiles.x, clickedMapTile.mapTiles.y)
  if (!playersOnTile) return null

  function handleClickPlayerPortrait(otherPlayerId: string) {
    setOtherPlayerId(otherPlayerId)
    openModalRightCenter(EPanelsRightCenter.OtherPlayerPanel)
  }

  const onClose = () => {
    resetModalTopCenter()
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
            {otherPlayer.name
              ? otherPlayer.name +
                (otherPlayer.nickname ? ` (${otherPlayer.nickname})` : "") +
                " " +
                otherPlayer.secondName
              : otherPlayer.otherPlayerId}
            <Button
              onClick={() => handleClickPlayerPortrait(otherPlayer.otherPlayerId)}
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
