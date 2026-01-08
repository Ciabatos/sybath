"use client"

import styles from "@/components/panels/styles/PanelMapTileDetail.module.css"
import { Button } from "@/components/ui/button"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { X } from "lucide-react"

const terrainData = {
  Jungle: {
    name: "Dense Forest",
    description:
      "A thick woodland filled with ancient trees and hidden paths. Wildlife thrives here, but danger lurks in the shadows.",
    resources: ["Wood", "Herbs", "Game"],
    difficulty: "Medium",
    encounters: ["Wolves", "Bandits", "Wild Boars"],
  },
  Grasslands: {
    name: "Dense Forest",
    description:
      "A thick woodland filled with ancient trees and hidden paths. Wildlife thrives here, but danger lurks in the shadows.",
    resources: ["Wood", "Herbs", "Game"],
    difficulty: "Medium",
    encounters: ["Wolves", "Bandits", "Wild Boars"],
  },
  Savannah: {
    name: "Mountain Peak",
    description:
      "Towering peaks covered in snow and ice. The air is thin and the paths treacherous, but valuable minerals can be found.",
    resources: ["Iron Ore", "Stone", "Gems"],
    difficulty: "Hard",
    encounters: ["Mountain Trolls", "Eagles", "Frost Giants"],
  },
  Plains: {
    name: "Open Plains",
    description:
      "Vast grasslands stretching to the horizon. Easy to traverse but offers little cover from enemies or weather.",
    resources: ["Grain", "Livestock", "Wild Flowers"],
    difficulty: "Easy",
    encounters: ["Raiders", "Wild Horses", "Nomads"],
  },
  Desert: {
    name: "Arid Desert",
    description:
      "Endless sand dunes under a scorching sun. Water is scarce and the heat can be deadly to the unprepared.",
    resources: ["Sand", "Cactus", "Ancient Artifacts"],
    difficulty: "Hard",
    encounters: ["Sand Wurms", "Desert Bandits", "Scorpions"],
  },
  Marsh: {
    name: "Deep Waters",
    description:
      "A vast body of water, whether lake, river, or sea. Rich with fish but dangerous for those who cannot swim.",
    resources: ["Fish", "Pearls", "Seaweed"],
    difficulty: "Medium",
    encounters: ["Pirates", "Sea Monsters", "Sirens"],
  },
  Shrubland: {
    name: "Settlement",
    description:
      "A small village where travelers can rest, trade, and gather information. The locals are friendly but wary of strangers.",
    resources: ["Trade Goods", "Information", "Supplies"],
    difficulty: "Safe",
    encounters: ["Merchants", "Guards", "Villagers"],
  },
}

export default function PanelMapTileDetail() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { clickedTile } = useMapTileActions()

  const onClose = () => {
    resetModalRightCenter()
  }

  console.log("clickedTile in PanelMapTileDetail:", clickedTile?.terrainTypes.name)
  const terrain = terrainData[clickedTile?.terrainTypes.name as keyof typeof terrainData]
  // const terrain = terrainData["Plains"]

  const gridPosition = { x: 10, y: 20 } // Example position, replace with actual data

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <div className={styles.header}>
          <div className={styles.titleSection}>
            <h2 className={styles.title}>{terrain.name}</h2>
            {gridPosition && (
              <span className={styles.coordinates}>
                [{gridPosition.x}, {gridPosition.y}]
              </span>
            )}
          </div>
          <Button
            onClick={onClose}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
          >
            <X className={styles.closeIcon} />
          </Button>
        </div>

        <div className={styles.content}>
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Description</h3>
            <p className={styles.description}>{terrain.description}</p>
          </section>

          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Difficulty</h3>
            <div
              className={styles.difficultyBadge}
              data-difficulty={terrain.difficulty.toLowerCase()}
            >
              {terrain.difficulty}
            </div>
          </section>

          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Available Resources</h3>
            <div className={styles.resourceList}>
              {terrain.resources.map((resource) => (
                <div
                  key={resource}
                  className={styles.resourceItem}
                >
                  <span className={styles.resourceIcon}>📦</span>
                  <span className={styles.resourceName}>{resource}</span>
                </div>
              ))}
            </div>
          </section>

          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Possible Encounters</h3>
            <div className={styles.encounterList}>
              {terrain.encounters.map((encounter) => (
                <div
                  key={encounter}
                  className={styles.encounterItem}
                >
                  <span className={styles.encounterIcon}>⚔️</span>
                  <span className={styles.encounterName}>{encounter}</span>
                </div>
              ))}
            </div>
          </section>

          <section className={styles.section}>
            <div className={styles.actionButtons}>
              <Button className={styles.actionButton}>Explore</Button>
              <Button
                className={styles.actionButton}
                variant='outline'
              >
                Set Camp
              </Button>
              <Button
                className={styles.actionButton}
                variant='outline'
              >
                Quick Travel
              </Button>
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}
