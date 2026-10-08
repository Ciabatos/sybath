// GENERATED CODE - DO EDIT MANUALLY - createNestedPanels.hbs

"use client"

import { TPlayerEnergy } from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { usePlayerEnergyBar } from "@/methods/hooks/players/composite/usePlayerEnergyBar"
import { Flame } from "lucide-react"
import styles from "./styles/PlayerEnergyBar.module.css"

type TLevel = "high" | "mid" | "low"

function getLevel(percent: number): TLevel {
  if (percent >= 60) return "high"
  if (percent >= 30) return "mid"
  return "low"
}

/**
 * Świadoma duplikacja helpera z `components/trade/tradeTime.ts` — nie chcemy
 * ciągnąć modułu z trade do HUD. Jeśli pojawi się trzecie użycie, wyciągnij
 * to do wspólnego miejsca.
 */
function formatRelativeAge(value: string): string {
  const ms = Date.parse(value)
  if (!Number.isFinite(ms)) return "—"

  const seconds = Math.round((Date.now() - ms) / 1000)

  if (seconds < 60) return "just now"
  if (seconds < 3600) return `${Math.round(seconds / 60)}m ago`
  if (seconds < 86400) return `${Math.round(seconds / 3600)}h ago`
  return `${Math.round(seconds / 86400)}d ago`
}

export default function PlayerEnergyBar() {
  const { playerEnergy } = usePlayerEnergyBar()

  // Atom jest kluczowany po `lastRegeneratedAt`, więc wpisów może być kilka —
  // po każdej regeneracji powstaje nowy. HUD pokazuje stan bieżący, nie historię.
  const latest = Object.values(playerEnergy).reduce<TPlayerEnergy | null>((newest, energy) => {
    if (!newest) return energy
    return Date.parse(energy.lastRegeneratedAt) > Date.parse(newest.lastRegeneratedAt) ? energy : newest
  }, null)

  if (!latest) {
    return (
      <div className={styles.panel}>
        <p className={styles.empty}>No energy data</p>
      </div>
    )
  }

  // `currentEnergy` to liczba, nie procent — poprzednio brzmiało "7%" przy 7/10.
  const max = latest.maxEnergy > 0 ? latest.maxEnergy : 0
  const percent = max > 0 ? Math.max(0, Math.min(100, (latest.currentEnergy / max) * 100)) : 0
  const level = getLevel(percent)

  return (
    <div
      className={styles.panel}
      data-level={level}
    >
      <div className={styles.header}>
        <span className={styles.icon}>
          <Flame className={styles.iconGlyph} />
        </span>
        <span className={styles.label}>Energy</span>
        <span className={styles.regen}>regen {formatRelativeAge(latest.lastRegeneratedAt)}</span>
      </div>

      <div className={styles.readout}>
        <span className={styles.current}>{latest.currentEnergy}</span>
        <span className={styles.max}>/{max}</span>
        <span className={styles.percent}>{Math.round(percent)}%</span>
      </div>

      <div
        className={styles.track}
        role='progressbar'
        aria-label='Energy'
        aria-valuenow={latest.currentEnergy}
        aria-valuemin={0}
        aria-valuemax={max}
      >
        <span
          className={styles.fill}
          style={{ width: `${percent}%` }}
        />
      </div>
    </div>
  )
}