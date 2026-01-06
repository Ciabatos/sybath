import PanelParty from "@/components/panels/PanelParty"
import { PanelPlayerAbilities } from "@/components/panels/PanelPlayerAbilities"
import { PanelPlayerInventory } from "@/components/panels/PanelPlayerInventory"
import { PanelPlayerSkills } from "@/components/panels/PanelPlayerSkills"
import styles from "@/components/panels/styles/PanelPlayerPanel.module.css"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { Avatar, AvatarFallback, AvatarImage } from "@radix-ui/react-avatar"
import { X } from "lucide-react"
import { useState } from "react"

type Props = {
  closePanel: () => void
}

export default function PanelPlayerPanel({ closePanel }: Props) {
  const [isPartyVisible, setIsPartyVisible] = useState(false)
  const { setModalLeftTopBar } = useModalLeftTopBar()

  function handleClosePanel() {
    setModalLeftTopBar(EPanelsLeftTopBar.PlayerPortrait)
  }
  return (
    <div className={styles.overlay}>
      <div className={styles.panelsContainer}>
        <div className={styles.panel}>
          <Button
            onClick={handleClosePanel}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
          >
            <X className={styles.closeButtonIcon} />
          </Button>

          <div className={styles.header}>
            <Avatar className={styles.avatar}>
              <AvatarImage
                src={"https://github.com/shadcn.png"}
                alt='Hero'
                className={styles.avatarImage}
              />
              <AvatarFallback className={styles.avatarFallback}></AvatarFallback>
            </Avatar>
            <div className={styles.headerInfo}>
              <h2 className={styles.heroName}>Pigeon Knight</h2>
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
                <div className={styles.statsContent}>
                  <p>Health: 140/140</p>
                  <p>Stamina: 110/110</p>
                  <p>Resolve: 70/70</p>
                  <p>Initiative: 81</p>
                </div>
              </TabsContent>

              <TabsContent
                value='Inventory'
                className={styles.tabsContentInventory}
              >
                <PanelPlayerInventory
                  columns={8}
                  rows={6}
                />
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
                <p className={styles.textContent}>
                  Knowledge represents what the hero knows about other characters and locations from the World Map.
                </p>
              </TabsContent>
            </Tabs>
          </div>

          <Button
            variant='ghost'
            size='lg'
            onClick={() => setIsPartyVisible(!isPartyVisible)}
            className={styles.toggleButton}
          >
            {isPartyVisible ? "Hide Party" : "Show Party"}
          </Button>
        </div>

        {isPartyVisible && <PanelParty avatarUrl={"https://github.com/shadcn.png"} />}
      </div>
    </div>
  )
}
