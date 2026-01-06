import type React from "react"
import styles from "@/components/panels/styles/PanelPlayerKnowledge.module.css"
import { Book, MapPin, Users, Scroll, Crown, Skull } from "lucide-react"

type KnowledgeItemProps = {
  icon: React.ReactNode
  title: string
  description: string
  level: "Known" | "Partial" | "Unknown"
}

function KnowledgeItem({ icon, title, description, level }: KnowledgeItemProps) {
  return (
    <div className={styles.knowledgeItem}>
      <div className={styles.knowledgeIcon}>{icon}</div>
      <div className={styles.knowledgeInfo}>
        <div className={styles.knowledgeHeader}>
          <h4 className={styles.knowledgeTitle}>{title}</h4>
          <span className={`${styles.knowledgeLevel} ${styles[`level${level}`]}`}>{level}</span>
        </div>
        <p className={styles.knowledgeDescription}>{description}</p>
      </div>
    </div>
  )
}

type KnowledgeCategoryProps = {
  title: string
  items: Array<{
    icon: React.ReactNode
    title: string
    description: string
    level: "Known" | "Partial" | "Unknown"
  }>
}

function KnowledgeCategory({ title, items }: KnowledgeCategoryProps) {
  return (
    <div className={styles.category}>
      <h3 className={styles.categoryTitle}>{title}</h3>
      <div className={styles.categoryItems}>
        {items.map((item, index) => (
          <KnowledgeItem key={index} {...item} />
        ))}
      </div>
    </div>
  )
}

export function PanelPlayerKnowledge() {
  const locationKnowledge = [
    {
      icon: <MapPin />,
      title: "The Northern Wastes",
      description: "A frozen wasteland inhabited by fierce barbarian tribes and ancient creatures.",
      level: "Known" as const,
    },
    {
      icon: <MapPin />,
      title: "Castle Grimwald",
      description: "An abandoned fortress rumored to be haunted by the spirits of fallen knights.",
      level: "Partial" as const,
    },
    {
      icon: <MapPin />,
      title: "Port of Shadows",
      description: "A mysterious harbor town where smugglers and pirates conduct their business.",
      level: "Unknown" as const,
    },
  ]

  const factionKnowledge = [
    {
      icon: <Crown />,
      title: "The Crown Guard",
      description: "Elite soldiers sworn to protect the realm and uphold the king's law.",
      level: "Known" as const,
    },
    {
      icon: <Users />,
      title: "The Mercenary Guild",
      description: "A loose organization of sellswords and warriors for hire.",
      level: "Known" as const,
    },
    {
      icon: <Skull />,
      title: "The Dark Brotherhood",
      description: "A secretive cult that worships ancient gods and practices forbidden magic.",
      level: "Partial" as const,
    },
  ]

  const loreKnowledge = [
    {
      icon: <Book />,
      title: "The Great War",
      description: "A devastating conflict that shaped the current political landscape.",
      level: "Known" as const,
    },
    {
      icon: <Scroll />,
      title: "Ancient Prophecies",
      description: "Cryptic writings that foretell the return of a legendary hero.",
      level: "Partial" as const,
    },
  ]

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <p className={styles.headerText}>
          Knowledge represents what your hero has learned about the world, its locations, factions, and ancient lore.
        </p>
      </div>

      <KnowledgeCategory title="Locations" items={locationKnowledge} />
      <KnowledgeCategory title="Factions" items={factionKnowledge} />
      <KnowledgeCategory title="Lore" items={loreKnowledge} />
    </div>
  )
}
