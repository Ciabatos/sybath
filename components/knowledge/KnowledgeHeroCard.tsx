"use client"

import PlayerPortrait from "@/components/players/PlayerPortrait"
import { TPlayerKnownPlayers } from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useSetOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { MapPin } from "lucide-react"
import styles from "./styles/PlayerKnowledge.module.css"

type TProps = {
  player: TPlayerKnownPlayers
}

export function KnowledgeHeroCard({ player }: TProps) {
  const { openModalRightCenter } = useModalRightCenter()
  const setOtherPlayerId = useSetOtherPlayerId()

  function handleClick() {
    setOtherPlayerId(player.otherPlayerId)
    openModalRightCenter(EPanelsRightCenter.OtherPlayerPanel)
  }

  const fullName = [player.name, player.secondName].filter(Boolean).join(" ")
  const displayName = fullName || player.otherPlayerId

  // Pozycja jest realnym polem z bazy, ale bywa pusta — wtedy jej nie pokazujemy.
  const hasPosition = player.x !== null && player.x !== undefined
  const lastSeen = `Map ${player.mapId} · (${player.x}, ${player.y})`

  return (
    <button
      type='button'
      onClick={handleClick}
      className={styles.heroCard}
    >
      {/* PlayerPortrait ma stałe 5.5rem, więc skalujemy go lokalnie —
          poprzednia wersja wpychała 88px portret do 44px ramki. */}
      <span className={styles.heroPortrait}>
        <PlayerPortrait imagePortrait={player.imagePortrait || null} />
      </span>

      <span className={styles.heroInfo}>
        <span className={styles.heroName}>{displayName}</span>
        {player.nickname && <span className={styles.heroNickname}>“{player.nickname}”</span>}

        {hasPosition && (
          <span className={styles.heroMeta}>
            <MapPin className={styles.heroMetaIcon} />
            {lastSeen}
          </span>
        )}
      </span>
    </button>
  )
}