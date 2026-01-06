"use client"
import { PanelPlayerInventory } from "@/components/panels/PanelPlayerInventory"
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
            <AvatarFallback className={styles.avatarFallback}>{"https://github.com/shadcn.png"}</AvatarFallback>
          </Avatar>
          <div className={styles.headerInfo}>
            <h2 className={styles.heroName}>Vet. Baldomar</h2>
            <p className={styles.heroTitle}>The Dog</p>
          </div>
        </div>

        <div className={`${styles.mainContent} ${!isPartyVisible ? styles.mainContentExpanded : ""}`}>
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
              <p className={styles.textContent}>
                Skills slużą do pokazania jakie umiejętności posiada postać. Można je przekazywać innym postaciom ale
                nie są to aktywne abilities
              </p>
            </TabsContent>

            <TabsContent
              value='Abilities'
              className={styles.tabsContent}
            >
              <p className={styles.textContent}>
                Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i
                innych sytuacjach, ability powstaja jeżeli masz różne kombinacje skills, stats i knowledge.
                {/* <PanelPlayerAbilities /> */}
              </p>
            </TabsContent>

            <TabsContent
              value='Knowledge'
              className={styles.tabsContent}
            >
              <p className={styles.textContent}>
                Knowledge jest to wiedza danego herosa najczęsciej o innych postaciach, lokalizacjach z Mapy Świata
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

        {isPartyVisible && (
          <div className={styles.partySection}>
            <Tabs
              defaultValue='Units'
              className={styles.partyTabs}
            >
              <TabsList className={styles.partyTabsList}>
                <TabsTrigger
                  value='Units'
                  className={styles.tabsTrigger}
                >
                  Units
                </TabsTrigger>
                <TabsTrigger
                  value='Party Inventory'
                  className={styles.tabsTrigger}
                >
                  Party Inventory
                </TabsTrigger>
              </TabsList>

              <TabsContent
                value='Units'
                className={styles.tabsContent}
              >
                <p className={styles.partyUnitsContent}>Party Leader</p>
                <div className={styles.partyLeaderContainer}>
                  <Avatar className={styles.partyAvatar}>
                    <AvatarImage
                      src={"https://github.com/shadcn.png"}
                      alt='Leader'
                      className={styles.avatarImage}
                    />
                    <AvatarFallback className={styles.avatarFallback}>L</AvatarFallback>
                  </Avatar>
                  <Button
                    variant='outline'
                    size='sm'
                    className={styles.formationButton}
                  >
                    Formation →
                  </Button>
                </div>
              </TabsContent>

              <TabsContent
                value='Party Inventory'
                className={styles.tabsContent}
              >
                <p className={styles.textContent}>Party inventory system coming soon...</p>
              </TabsContent>
            </Tabs>
          </div>
        )}
      </div>
    </div>
  )
}
