"use client"

import PlayerPortrait from "@/components/players/PlayerPortrait"
import SquadPortrait from "@/components/squad/SquadPortrait"
import { Button } from "@/components/ui/button"
import { useModalBottomLeft } from "@/methods/hooks/modals/useModalBottomLeft"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useSetOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import usePlayersOnTile from "@/methods/hooks/world/composite/usePlayersOnTile"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { MapPin, UserRound, X } from "lucide-react"
import styles from "./styles/PlayersOnTile.module.css"

export default function PlayersOnTile() {
  const { resetModalBottomLeft } = useModalBottomLeft()
  const { openModalRightCenter } = useModalRightCenter()
  const setOtherPlayerId = useSetOtherPlayerId()

  const { clickedMapTile } = useMapTileActions()

  const tileX = clickedMapTile?.mapTiles.x ?? 0
  const tileY = clickedMapTile?.mapTiles.y ?? 0
  const { playersOnTile } = usePlayersOnTile(tileX, tileY)

  function handleClickPlayerPortrait(otherPlayerId: string) {
    setOtherPlayerId(otherPlayerId)
    openModalRightCenter(EPanelsRightCenter.OtherPlayerPanel)
  }

  const onClose = () => {
    resetModalBottomLeft()
  }

  // Bez klikniętego kafelka hook pyta o (0, 0) i pokazywałby cudzy kafel.
  if (!clickedMapTile) return null

  const players = Object.values(playersOnTile ?? {})

  // Kafelek ma warstwę krajobrazu, terenu i miasta — pokazujemy tę, która jest.
  const tileTitle = clickedMapTile.landscapeTypes?.name || clickedMapTile.terrainTypes?.name || "Unknown tile"
  const tileSubtitle = [clickedMapTile.cities?.name, clickedMapTile.districts?.name]
    .filter(Boolean)
    .join(" · ")

  return (
    <div className={styles.panel}>
      <header className={styles.header}>
        <div className={styles.headerInfo}>
          <h3 className={styles.title}>{tileTitle}</h3>

          <span className={styles.subtitle}>
            <MapPin className={styles.subtitleIcon} />
            {tileSubtitle || `Tile (${tileX}, ${tileY})`}
          </span>
        </div>

        <span className={styles.count}>
          {players.length}
          {players.length === 1 ? " hero" : " heroes"}
        </span>

        <Button
          onClick={onClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
          aria-label='Close'
        >
          <X className={styles.closeIcon} />
        </Button>
      </header>

      {players.length === 0 ? (
        <div className={styles.empty}>
          <UserRound className={styles.emptyIcon} />
          <p className={styles.emptyText}>Nobody else stands on this tile.</p>
        </div>
      ) : (
        <ul className={styles.list}>
          {players.map((otherPlayer) => {
            const fullName = [otherPlayer.name, otherPlayer.secondName].filter(Boolean).join(" ")
            const displayName = fullName || otherPlayer.otherPlayerId
            const hasSquad = Boolean(otherPlayer.squadImagePortrait || otherPlayer.squadName)

            return (
              <li key={otherPlayer.otherPlayerId}>
                <button
                  type='button'
                  onClick={() => handleClickPlayerPortrait(otherPlayer.otherPlayerId)}
                  className={styles.heroRow}
                >
                  <span className={styles.heroUnit}>
                    {/* PlayerPortrait ma stałe 5.5rem, więc skalujemy go lokalnie. */}
                    <span className={styles.portrait}>
                      <PlayerPortrait imagePortrait={otherPlayer.imagePortrait || null} />
                    </span>

                    <span className={styles.heroInfo}>
                      <span className={styles.heroName}>{displayName}</span>
                      {otherPlayer.nickname && <span className={styles.heroNickname}>“{otherPlayer.nickname}”</span>}
                    </span>
                  </span>

                  {hasSquad && (
                    <span className={styles.squadUnit}>
                      {/* SquadPortrait zwraca null dla pustego obrazu — nie zostawiamy
                          wtedy pustego koła, pokazujemy samą nazwę. */}
                      {otherPlayer.squadImagePortrait && (
                        <span className={styles.squadPortrait}>
                          <SquadPortrait squadImagePortrait={otherPlayer.squadImagePortrait} />
                        </span>
                      )}

                      {otherPlayer.squadName && <span className={styles.squadName}>{otherPlayer.squadName}</span>}
                    </span>
                  )}
                </button>
              </li>
            )
          })}
        </ul>
      )}
    </div>
  )
}