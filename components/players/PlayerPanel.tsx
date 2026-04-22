"use client"
import { PlayerAbilities } from "@/components/attributes/PlayerAbilities"
import { PlayerSkills } from "@/components/attributes/PlayerSkills"
import PlayerStats from "@/components/attributes/PlayerStats"
import { PlayerCombinedInventory } from "@/components/inventory/PlayerCombinedInventory"
import { PlayerKnowledge } from "@/components/knowledge/PlayerKnowledge"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import PlayerSquadPortrait from "@/components/players/PlayerSquadPortrait"
import PlayerSwitchButton from "@/components/players/PlayerSwitchButton"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { useActivePlayerSquad } from "@/methods/hooks/squad/composite/useActivePlayerSquad"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { X } from "lucide-react"
import styles from "./styles/PlayerPanel.module.css"

export default function PlayerPanel() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { activePlayerProfile } = useActivePlayerProfile()
  const { activePlayerSquad } = useActivePlayerSquad()

  function onClose() {
    openModalLeftTopBar(EPanelsLeftTopBar.PlayerRibbon)
  }

  const name = activePlayerProfile?.name
  const secondName = activePlayerProfile?.secondName
  const nickname = activePlayerProfile?.nickname

  return (
    <div className={styles.panelsContainer}>
      <div className={styles.panel}>
        <Button
          onClick={onClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <X className={styles.closeButtonIcon} />
        </Button>

        <div className={styles.header}>
          <PlayerSquadPortrait squadImagePortrait={activePlayerSquad?.squadImagePortrait} />
          <PlayerPortrait imagePortrait={activePlayerProfile?.imagePortrait} />
          <div className={styles.headerInfo}>
            <h2 className={styles.heroName}>
              {name} {secondName}
            </h2>
            <p className={styles.heroTitle}>Inni głosują za nickiem lub nazywają{nickname}</p>
          </div>
        </div>

        <div className={styles.mainContent}>
          <Tabs
            defaultValue='Stats'
            className={styles.tabs}
          >
            <TabsList className={styles.tabsList}>
              <TabsTrigger
                value='Stats'
                className={styles.tabsTrigger}
              >
                Stats
              </TabsTrigger>
              <TabsTrigger
                value='Inventory'
                className={styles.tabsTrigger}
              >
                Inventory
              </TabsTrigger>
              <TabsTrigger
                value='Skills'
                className={styles.tabsTrigger}
              >
                Skills
              </TabsTrigger>
              <TabsTrigger
                value='Abilities'
                className={styles.tabsTrigger}
              >
                Abilities
              </TabsTrigger>
              <TabsTrigger
                value='Knowledge'
                className={styles.tabsTrigger}
              >
                Knowledge
              </TabsTrigger>
            </TabsList>

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
          </Tabs>
        </div>
      </div>
      <div className={styles.playerSwitchButtonContainer}>
        <PlayerSwitchButton />
      </div>
    </div>
  )
}
