"use client"

import SquadPlayersProfiles from "@/components/squad/SquadPlayersProfiles"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { Backpack, LandPlot, X } from "lucide-react"
import styles from "./styles/PanelPlayerSquad.module.css"

export default function PanelPlayerSquad() {
  const { openModalLeftTopBar } = useModalLeftTopBar()

  function onClose() {
    openModalLeftTopBar(EPanelsLeftTopBar.PlayerRibbon)
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <div className={styles.header}>
          <h2 className={styles.title}>Squad</h2>
          <Button
            onClick={onClose}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
          >
            <X className={styles.closeIcon} />
          </Button>
        </div>

        {/* Squad Members Grid */}
        <div className={styles.content}>
          <SquadPlayersProfiles />
          {/* Formation */}
          <div className={styles.section}>
            <Button
              className={styles.actionButton}
              size='lg'
            >
              <LandPlot />
              Formation
            </Button>
          </div>

          {/* Shared Inventory */}
          <div className={styles.section}>
            <Button
              className={styles.actionButton}
              size='lg'
            >
              <Backpack />
              Squad Inventory
            </Button>
          </div>

          {/* Squad Stats */}
          <div className={styles.statsSection}>
            <h3 className={styles.statsTitle}>Squad Logistics</h3>
            <div className={styles.statsGrid}>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Total Heroes</span>
              </div>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Mules</span>
                <span className={styles.statValue}></span>
              </div>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Total Capacity</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
