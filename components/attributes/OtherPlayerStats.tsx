"use client"

import Stat from "@/components/attributes/Stat"
import getIcon from "@/methods/functions/icons/getIcon"
import { useOtherPlayerStats } from "@/methods/hooks/attributes/composite/useOtherPlayerStats"
import styles from "./styles/PlayerStats.module.css"

export default function OtherPlayerStats() {
  const { combinedOtherPlayerStats } = useOtherPlayerStats()

  return (
    <div className={styles.container}>
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Stats</h3>
        <div className={styles.statsGrid}>
          {combinedOtherPlayerStats.map((playerStat) => (
            <Stat
              key={playerStat.id}
              icon={getIcon(playerStat.image)}
              name={playerStat.name}
              value={playerStat.value}
              maxValue={10}
              description={playerStat.description}
            />
          ))}
        </div>
      </div>
    </div>
  )
}
