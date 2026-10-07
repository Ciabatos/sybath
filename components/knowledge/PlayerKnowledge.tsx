"use client"

import { KnowledgeEmpty, KnowledgeSection } from "@/components/knowledge/KnowledgeSection"
import { KnowledgeHeroCard } from "@/components/knowledge/KnowledgeHeroCard"
import { KnowledgeRegionCard } from "@/components/knowledge/KnowledgeRegionCard"
import { KNOWLEDGE_EMBLEM, KNOWLEDGE_HEADER, KNOWLEDGE_SECTIONS } from "@/components/knowledge/knowledgeLayout"
import { TKnownMapRegion } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import usePlayerKnownMapRegions from "@/methods/hooks/knowledge/composite/usePlayerKnownMapRegions"
import usePlayerKnownPlayers from "@/methods/hooks/knowledge/composite/usePlayerKnownPlayers"
import { EPanelsTopCenter } from "@/types/enumeration/EPanelsTopCenter"
import { Button } from "@/components/ui/button"
import styles from "./styles/PlayerKnowledge.module.css"

export function PlayerKnowledge() {
  const { playerKnownPlayers } = usePlayerKnownPlayers()
  const { knownMapRegion } = usePlayerKnownMapRegions()
  const { openModalTopCenter } = useModalTopCenter()

  const Emblem = KNOWLEDGE_EMBLEM
  const heroes = Object.values(playerKnownPlayers)
  const regionGroups = Object.groupBy(Object.values(knownMapRegion), (region) => region.regionId)
  const regionEntries = Object.entries(regionGroups).filter(
    (entry): entry is [string, TKnownMapRegion[]] => Array.isArray(entry[1]) && entry[1].length > 0,
  )

  function openOtherPlayerKnowledgeRequests() {
    openModalTopCenter(EPanelsTopCenter.OtherPlayerKnowledgeRequests)
  }

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <span className={styles.headerEmblem}>
          <Emblem className={styles.headerEmblemIcon} />
        </span>
        <div className={styles.headerInfo}>
          <h2 className={styles.headerTitle}>{KNOWLEDGE_HEADER.title}</h2>
          <p className={styles.headerSubtitle}>{KNOWLEDGE_HEADER.subtitle}</p>
        </div>
        <Button
          onClick={openOtherPlayerKnowledgeRequests}
          variant='outline'
          size='sm'
          className={styles.requestsButton}
        >
          {KNOWLEDGE_HEADER.requestsLabel}
        </Button>
      </header>

      <KnowledgeSection
        config={KNOWLEDGE_SECTIONS.heroes}
        count={heroes.length}
      >
        {heroes.length === 0 ? (
          <KnowledgeEmpty text={KNOWLEDGE_SECTIONS.heroes.emptyText} />
        ) : (
          <div className={styles.heroGrid}>
            {heroes.map((hero) => (
              <KnowledgeHeroCard
                key={hero.otherPlayerId}
                player={hero}
              />
            ))}
          </div>
        )}
      </KnowledgeSection>

      <KnowledgeSection
        config={KNOWLEDGE_SECTIONS.regions}
        count={regionEntries.length}
      >
        {regionEntries.length === 0 ? (
          <KnowledgeEmpty text={KNOWLEDGE_SECTIONS.regions.emptyText} />
        ) : (
          <div className={styles.regionList}>
            {regionEntries.map(([regionId, regions]) => (
              <KnowledgeRegionCard
                key={regionId}
                regionName={regions[0].regionName}
                tiles={regions}
              />
            ))}
          </div>
        )}
      </KnowledgeSection>

      <KnowledgeSection config={KNOWLEDGE_SECTIONS.factions}>
        <KnowledgeEmpty text={KNOWLEDGE_SECTIONS.factions.emptyText} />
      </KnowledgeSection>

      <KnowledgeSection config={KNOWLEDGE_SECTIONS.crimes}>
        <KnowledgeEmpty text={KNOWLEDGE_SECTIONS.crimes.emptyText} />
      </KnowledgeSection>
    </div>
  )
}