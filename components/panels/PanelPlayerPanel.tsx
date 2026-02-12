import { PanelPlayerAbilities } from "@/components/panels/PanelPlayerAbilities"
import { PanelPlayerInventory } from "@/components/panels/PanelPlayerInventory"
import { PanelPlayerKnowledge } from "@/components/panels/PanelPlayerKnowledge"
import { PanelPlayerSkills } from "@/components/panels/PanelPlayerSkills"
import { PanelPlayerStats } from "@/components/panels/PanelPlayerStats"
import PlayerSwitchButton from "@/components/players/styles/PlayerSwitchButton"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { createImage } from "@/methods/functions/util/createImage"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { useActivePlayerProfile } from "@/methods/hooks/players/composite/useActivePlayerProfile"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { Avatar, AvatarFallback, AvatarImage } from "@radix-ui/react-avatar"
import { X } from "lucide-react"
import styles from "./styles/PanelPlayerPanel.module.css"

export default function PanelPlayerPanel() {
  const { openModalLeftTopBar } = useModalLeftTopBar()
  const { createPlayerPortrait } = createImage()
  const { activePlayerProfile } = useActivePlayerProfile()

  function onClose() {
    openModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPortrait)
  }

  const name = activePlayerProfile?.name
  const secondName = activePlayerProfile?.secondName
  const nickname = activePlayerProfile?.nickname
  const avatarUrl = createPlayerPortrait(activePlayerProfile?.imagePortrait)
  const avatarFallback = "VB"

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
          <Avatar className={styles.avatar}>
            <AvatarImage
              src={avatarUrl}
              alt='Hero'
              className={styles.avatarImage}
            />
            <AvatarFallback className={styles.avatarFallback}>{avatarFallback}</AvatarFallback>
          </Avatar>
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
              <PanelPlayerStats />
            </TabsContent>

            <TabsContent
              value='Inventory'
              className={styles.tabsContentInventory}
            >
              <PanelPlayerInventory />
            </TabsContent>

            <TabsContent
              value='Skills'
              className={styles.tabsContent}
            >
              <PanelPlayerSkills />
            </TabsContent>

            <TabsContent
              value='Abilities'
              className={styles.tabsContent}
            >
              <PanelPlayerAbilities />
            </TabsContent>

            <TabsContent
              value='Knowledge'
              className={styles.tabsContent}
            >
              <PanelPlayerKnowledge />
            </TabsContent>
          </Tabs>
        </div>
      </div>
      <PlayerSwitchButton />
    </div>
  )
}
