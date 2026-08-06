import OtherPlayerProfiles from "@/components/knowledge/OtherPlayerProfiles"
import { Button } from "@/components/ui/button"
import usePlayerKnownMapRegions from "@/methods/hooks/knowledge/composite/usePlayerKnownMapRegions"
import usePlayerKnownPlayers from "@/methods/hooks/knowledge/composite/usePlayerKnownPlayers"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { MapPin, Skull } from "lucide-react"
import styles from "./styles/PlayerKnowledge.module.css"

export function PlayerKnowledge() {
  const { playerKnownPlayers } = usePlayerKnownPlayers()
  const { knownMapRegion } = usePlayerKnownMapRegions()
  const { openModalTopCenter } = useModalTopCenter()

  const crimesKnowledge = [
    {
      icon: <Skull />,
      title: "Murder",
      description: "Murder of Serghios by Kako.",
      level: "Known" as const,
    },
    {
      icon: <Skull />,
      title: "Murder",
      description: "Murder of Pako by Kako.",
      level: "Partial" as const,
    },
  ]

  function openOtherPlayerKnowledgeRequests() {
    openModalTopCenter(EPanelsTopCenter.OtherPlayerKnowledgeRequests)
  }

  const regionGroups = Object.groupBy(Object.values(knownMapRegion), ({ regionId }) => regionId)

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <p className={styles.headerText}>
          Knowledge represents what your hero has learned about the world, its locations, factions, and ancient lore.
        </p>
      </div>

      <Button onClick={openOtherPlayerKnowledgeRequests}>Knowledge requests</Button>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Heroes</h3>
        <div className={styles.categoryItems}>
          {Object.entries(playerKnownPlayers).map(([key, player]) => (
            <div key={key}>
              <OtherPlayerProfiles playerProfile={player} />
            </div>
          ))}
        </div>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Factions</h3>
        <div className={styles.categoryItems}>
          {crimesKnowledge.map((item, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeIcon}>
                <MapPin />
              </div>
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>{item.title}</h4>
                  <span className={`${styles.knowledgeLevel} ${styles[`level${item.level}`]}`}>{item.level}</span>
                </div>
                <p className={styles.knowledgeDescription}>{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Regions</h3>
        {Object.entries(regionGroups).map(([regionId, regions]) => {
          if (!regions) return null

          const firstRegion = regions[0]

          return (
            <div
              key={regionId}
              className={styles.regionGroup}
            >
              <h4 className={styles.regionName}>{firstRegion.regionName}</h4>

              {regions.map((region) => (
                <div
                  key={`${region.mapId}${region.mapTileX}${region.mapTileY}`}
                  className={styles.knowledgeItem}
                >
                  <div className={styles.knowledgeIcon}>
                    <MapPin />
                  </div>

                  <div className={styles.knowledgeInfo}>
                    <div className={styles.knowledgeHeader}>
                      <h4 className={styles.knowledgeTitle}>
                        Tile ({region.mapTileX}, {region.mapTileY})
                      </h4>
                    </div>

                    <p className={styles.knowledgeDescription}>Map ID: {region.mapId}</p>
                  </div>
                </div>
              ))}
            </div>
          )
        })}
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Crimes</h3>
        <div className={styles.categoryItems}>
          {crimesKnowledge.map((item, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeIcon}>
                <MapPin />
              </div>
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>{item.title}</h4>
                  <span className={`${styles.knowledgeLevel} ${styles[`level${item.level}`]}`}>{item.level}</span>
                </div>
                <p className={styles.knowledgeDescription}>{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
