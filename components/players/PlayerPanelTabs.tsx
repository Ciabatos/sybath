"use client"

import { PlayerAbilities } from "@/components/attributes/PlayerAbilities"
import { PlayerSkills } from "@/components/attributes/PlayerSkills"
import PlayerStats from "@/components/attributes/PlayerStats"
import { PlayerCombinedInventory } from "@/components/inventory/PlayerCombinedInventory"
import { PlayerKnowledge } from "@/components/knowledge/PlayerKnowledge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Activity, Backpack, BookOpenText, Scroll, Zap } from "lucide-react"
import styles from "./styles/PlayerPanelTabs.module.css"

const TAB_ITEMS = [
  { value: "Stats", label: "Stats", icon: Activity },
  { value: "Inventory", label: "Bag", icon: Backpack },
  { value: "Skills", label: "Skills", icon: BookOpenText },
  { value: "Abilities", label: "Abilities", icon: Zap },
  { value: "Knowledge", label: "Lore", icon: Scroll },
] as const

/**
 * Poziomy pasek zakładek. Ikona nad etykietą, bo na telefonie szerokość kolumny
 * spada do ok. 60px i sama etykieta przestaje być czytelna.
 *
 * Wyzwalacze mają min. 44px wysokości (Apple HIG / WCAG 2.5.5) oraz
 * `touch-action: manipulation`, żeby dotknięcie nie czekało 300ms na podwójne
 * kliknięcie i nie przybliżało strony. Gdy ekran jest za wąski na pięć kolumn,
 * pasek przewija się w poziomie zamiast ściskać etykiety.
 */
export default function PlayerPanelTabs() {
  return (
    <Tabs
      defaultValue='Stats'
      className={styles.tabs}
    >
      <TabsList className={styles.tabsList}>
        {TAB_ITEMS.map(({ value, label, icon: Icon }) => (
          <TabsTrigger
            key={value}
            value={value}
            className={styles.tabsTrigger}
          >
            <Icon className={styles.tabsTriggerIcon} />
            <span className={styles.tabsTriggerLabel}>{label}</span>
          </TabsTrigger>
        ))}
      </TabsList>

      <div className={styles.panels}>
        <TabsContent
          value='Stats'
          className={styles.tabsContent}
        >
          <PlayerStats />
        </TabsContent>

        <TabsContent
          value='Inventory'
          className={styles.tabsContentInventory}
        >
          <PlayerCombinedInventory />
        </TabsContent>

        <TabsContent
          value='Skills'
          className={styles.tabsContent}
        >
          <PlayerSkills />
        </TabsContent>

        <TabsContent
          value='Abilities'
          className={styles.tabsContent}
        >
          <PlayerAbilities />
        </TabsContent>

        <TabsContent
          value='Knowledge'
          className={styles.tabsContent}
        >
          <PlayerKnowledge />
        </TabsContent>
      </div>
    </Tabs>
  )
}