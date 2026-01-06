"use client"

import styles from "@/components/panels/styles/PanelParty.module.css"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"

type Props = {
  avatarUrl: string
}

export default function PanelParty({ avatarUrl }: Props) {
  return (
    <div className={styles.partyPanel}>
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
                src={avatarUrl}
                alt='Leader'
                className={styles.avatarImage}
              />
              <AvatarFallback className={styles.avatarFallback}></AvatarFallback>
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
  )
}
