"use client"

import { TKnowledgeSectionConfig } from "@/components/knowledge/knowledgeLayout"
import { ReactNode } from "react"
import styles from "./styles/PlayerKnowledge.module.css"

type TProps = {
  config: TKnowledgeSectionConfig
  count?: number
  children: ReactNode
}

/** Nagłówek sekcji z emblematem, tytułem, licznikiem i ramką w stylu grawerunku. */
export function KnowledgeSection({ config, count, children }: TProps) {
  const Icon = config.icon

  return (
    <section className={styles.section}>
      <header className={styles.sectionHeader}>
        <span className={styles.sectionEmblem}>
          <Icon className={styles.sectionEmblemIcon} />
        </span>

        <h3 className={styles.sectionTitle}>{config.title}</h3>

        {count !== undefined && <span className={styles.sectionCount}>{count}</span>}
      </header>

      <div className={styles.sectionBody}>{children}</div>
    </section>
  )
}

export function KnowledgeEmpty({ text }: { text: string }) {
  return (
    <div className={styles.empty}>
      <span className={styles.emptyRule} />
      <p className={styles.emptyText}>{text}</p>
      <span className={styles.emptyRule} />
    </div>
  )
}