// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import styles from "./styles/CreatePlayerPanel.module.css"
import { Button } from "@/components/ui/button"
import { Palette, Swords, UserRound, X } from "lucide-react"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import CreatePlayerPanelBasics from "./CreatePlayerPanelBasics"
import CreatePlayerPanelStats from "./CreatePlayerPanelStats"
import CreatePlayerPanelAppearance from "./CreatePlayerPanelAppearance"

export default function CreatePlayerPanel() {
  const { resetModalTopCenter } = useModalTopCenter()

  function closeCreatePlayerPanel() {
    resetModalTopCenter()
  }

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={ closeCreatePlayerPanel }
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>

        <header className={styles.panelHeader}>
          <h2 className={styles.panelTitle}>Stwórz gracza</h2>
          <p className={styles.panelSubtitle}>
            Nowa postać zostanie dodana do kampanii po zatwierdzeniu.
          </p>
        </header>

        <Tabs defaultValue="basics" className={styles.tabs}>
          <TabsList className={styles.tabsList}>
            <TabsTrigger value="basics" className={styles.tabsTrigger}>
              <UserRound />
              Podstawowe
            </TabsTrigger>
            <TabsTrigger value="stats" className={styles.tabsTrigger}>
              <Swords />
              Statystyki
            </TabsTrigger>
            <TabsTrigger value="appearance" className={styles.tabsTrigger}>
              <Palette />
              Wygląd
            </TabsTrigger>
          </TabsList>

          <div className={styles.panelBody}>
            <TabsContent value="basics">
              <CreatePlayerPanelBasics />
            </TabsContent>
            <TabsContent value="stats">
              <CreatePlayerPanelStats />
            </TabsContent>
            <TabsContent value="appearance">
              <CreatePlayerPanelAppearance />
            </TabsContent>
          </div>
        </Tabs>

        <footer className={styles.panelFooter}>
          <p className={styles.footerHint}>
            Tryb podglądu — dane są mockowane i nie zostaną zapisane.
          </p>
          <div className={styles.footerActions}>
            <Button variant="outline" onClick={closeCreatePlayerPanel}>
              Anuluj
            </Button>
            <Button>Utwórz gracza</Button>
          </div>
        </footer>
      </div>
    </div>
  )
}
