// GENERATED CODE - DO EDIT MANUALLY - createListPanels.hbs
"use client"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import { TPlayerKnownPlayers } from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useSetOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { MapPin } from "lucide-react"
import styles from "./styles/OtherPlayerProfiles.module.css"

interface TOtherPlayerProfilesProps {
  playerProfile: TPlayerKnownPlayers
}

export default function OtherPlayerProfiles({ playerProfile }: TOtherPlayerProfilesProps) {
  const { openModalRightCenter } = useModalRightCenter()
  const setOtherPlayerId = useSetOtherPlayerId()

  function handleClickPlayerPortrait(otherPlayerId: string) {
    setOtherPlayerId(otherPlayerId)
    openModalRightCenter(EPanelsRightCenter.OtherPlayerPanel)
  }

  return (
    <div
      onClick={() => handleClickPlayerPortrait(playerProfile.otherPlayerId)}
      className={styles.listItem}
    >
      <div className={styles.listItemIcon}>
        <div className={styles.listItemIconEmoji}>
          <PlayerPortrait imagePortrait={playerProfile.imagePortrait} />
        </div>
      </div>
      <div className={styles.listItemContent}>
        <div className={styles.listItemHeader}>
          <h3 className={styles.listItemName}>
            {playerProfile.name
              ? playerProfile.name +
                (playerProfile.nickname ? ` (${playerProfile.nickname})` : "") +
                " " +
                playerProfile.secondName
              : playerProfile.otherPlayerId}
          </h3>
        </div>
      </div>
      <div className={styles.listItemStat}>{playerProfile.x ? <MapPin /> : ""}</div>
    </div>
  )
}
