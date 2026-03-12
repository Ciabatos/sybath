"use client"

import Stat from "@/components/attributes/Stat"
import getIcon from "@/methods/functions/icons/getIcon"
import { usePlayerStats } from "@/methods/hooks/attributes/composite/usePlayerStats"
import styles from "./styles/PlayerStats.module.css"

export default function PlayerStats() {
  const { combinedPlayerStats } = usePlayerStats()

  const physicalStats = combinedPlayerStats.filter((stat) => [1, 2, 3].includes(stat.id))
  const cunningStats = combinedPlayerStats.filter((stat) => [4, 5, 6].includes(stat.id))
  const mentalStats = combinedPlayerStats.filter((stat) => [7, 8, 9].includes(stat.id))

  return (
    <div className={styles.container}>
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Physical</h3>
        <div className={styles.statsGrid}>
          {physicalStats.map((playerStat) => (
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
        <h3 className={styles.sectionTitle}>Cunning</h3>
        <div className={styles.statsGrid}>
          {cunningStats.map((playerStat) => (
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
        <h3 className={styles.sectionTitle}>Mental</h3>
        <div className={styles.statsGrid}>
          {mentalStats.map((playerStat) => (
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
