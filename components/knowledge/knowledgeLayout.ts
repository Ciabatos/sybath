import { ComponentType } from "react"
import { MapPin, ScrollText, Shield, Skull, UserRound } from "lucide-react"

export type TKnowledgeSectionKey = "heroes" | "regions" | "factions" | "crimes"

/** Wystarczy dowolny komponent przyjmujący className — bez zależności od typu z lucide. */
export type TKnowledgeIcon = ComponentType<{ className?: string }>

export type TKnowledgeSectionConfig = {
  key: TKnowledgeSectionKey
  title: string
  icon: TKnowledgeIcon
  emptyText: string
  /** `false` dla sekcji bez jeszcze źródła danych — pokazują pustą ramkę z opisem. */
  hasDataSource: boolean
}

export const KNOWLEDGE_SECTIONS: Record<TKnowledgeSectionKey, TKnowledgeSectionConfig> = {
  heroes: {
    key: "heroes",
    title: "Heroes",
    icon: UserRound,
    emptyText: "You have not met anyone yet.",
    hasDataSource: true,
  },
  regions: {
    key: "regions",
    title: "Regions",
    icon: MapPin,
    emptyText: "No region charted. Travel the world to reveal it.",
    hasDataSource: true,
  },
  factions: {
    key: "factions",
    title: "Factions",
    icon: Shield,
    emptyText: "No faction stands yet. Faction data is not wired up.",
    hasDataSource: false,
  },
  crimes: {
    key: "crimes",
    title: "Crimes",
    icon: Skull,
    emptyText: "No crimes witnessed yet.",
    hasDataSource: false,
  },
}

export const KNOWLEDGE_HEADER = {
  title: "Codex",
  subtitle: "Everything your hero has seen, heard and pieced together.",
  requestsLabel: "Knowledge requests",
} as const

/**
 * Ikony z getIcon przyjmują klucze tekstowe, nie komponenty, więc trzymamy
 * tu komponenty lucide i mapujemy je w sekcjach bezpośrednio.
 * ScrollText używany jest jako emblemat nagłówka.
 */
export const KNOWLEDGE_EMBLEM = ScrollText