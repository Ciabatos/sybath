"use client"

import PlayerPanelTabs from "@/components/players/PlayerPanelTabs"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import SquadPortrait from "@/components/squad/SquadPortrait"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { usePlayerSquad } from "@/methods/hooks/squad/composite/usePlayerSquad"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { X } from "lucide-react"
import styles from "./styles/PlayerPanel.module.css"

export default function PlayerPanel() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { activePlayerProfile } = useActivePlayerProfile()
  const { activePlayerSquad } = usePlayerSquad()

  function onClose() {
    openModalLeftTopBar(EPanelsLeftTopBar.PlayerRibbonTop)
  }

  const name = activePlayerProfile?.name
  const secondName = activePlayerProfile?.secondName
  const nickname = activePlayerProfile?.nickname
  const squadImagePortrait = activePlayerSquad?.squadImagePortrait || null

  return (
    <div className={styles.panelsContainer}>
      <div className={styles.panel}>
        <header className={styles.header}>
          <div className={styles.portraits}>
            {squadImagePortrait && (
              <div className={styles.squadBadge}>
                <SquadPortrait squadImagePortrait={squadImagePortrait} />
              </div>
            )}
            <div className={styles.playerPortrait}>
              <PlayerPortrait imagePortrait={activePlayerProfile?.imagePortrait || null} />
            </div>
          </div>

          <div className={styles.headerInfo}>
            <h2 className={styles.heroName}>
              {name} {secondName}
            </h2>
            {nickname && <p className={styles.heroTitle}>@{nickname}</p>}
          </div>

          <Button
            onClick={onClose}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
            aria-label='Close'
          >
            <X className={styles.closeButtonIcon} />
          </Button>
        </header>

        <PlayerPanelTabs />

        <div className={styles.playerSwitchButtonContainer}>
          <PlayerSwitchButton />
        </div>
      </div>
    </div>
  )
}