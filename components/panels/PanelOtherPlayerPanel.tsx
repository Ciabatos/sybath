import { PlayerAbilities } from "@/components/attributes/PlayerAbilities"
import { PlayerSkills } from "@/components/attributes/PlayerSkills"
import PlayerStats from "@/components/attributes/PlayerStats"
import { PlayerCombinedInventory } from "@/components/inventory/PlayerCombinedInventory"
import { PlayerKnowledge } from "@/components/knowledge/PlayerKnowledge"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { Avatar, AvatarFallback, AvatarImage } from "@radix-ui/react-avatar"
import { X } from "lucide-react"
import styles from "./styles/PanelOtherPlayerPanel.module.css"

export default function PanelOtherPlayerPanel() {
  const { resetModalRightCenter } = useModalRightCenter()

  function onClose() {
    resetModalRightCenter()
  }

  const avatarUrl = "https://github.com/shadcn.png"
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
              src={avatarUrl || "/placeholder.svg"}
              alt='Hero'
              className={styles.avatarImage}
            />
            <AvatarFallback className={styles.avatarFallback}>{avatarFallback}</AvatarFallback>
          </Avatar>
          <div className={styles.headerInfo}>
            <h2 className={styles.heroName}>Das Man</h2>
            <p className={styles.heroTitle}>The Dog</p>
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
              <span className={`${styles.knowledgeLevel} ${styles[`levelKnown`]}`}>levelKnown</span>
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
    </div>
  )
}
