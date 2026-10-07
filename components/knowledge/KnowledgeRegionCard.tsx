"use client"

import { TKnownMapRegion } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { ChevronRight } from "lucide-react"
import { useState } from "react"
import styles from "./styles/PlayerKnowledge.module.css"

type TProps = {
  regionName: string
  tiles: TKnownMapRegion[]
}

/**
 * Karta regionu: nazwa i licznik kafelków zawsze widoczne, lista kafelków
 * rozwija się po kliknięciu. Dzięki temu wiele regionów mieści się bez
 * przewijania, a szczegóły są na wyciągnięcie ręki.
 *
 * Kafelki są sortowane po Y, potem X, żeby pas zachowywał przynajmniej
 * orientację przestrzenną regionu mimo braku siatki współrzędnych.
 */
export function KnowledgeRegionCard({ regionName, tiles }: TProps) {
  const [isOpen, setIsOpen] = useState(false)

  if (!tiles.length) return null

  const mapId = tiles[0].mapId

  const sortedTiles = [...tiles].sort((a, b) => a.mapTileY - b.mapTileY || a.mapTileX - b.mapTileX)

  return (
    <figure className={styles.region}>
      <button
        type='button'
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
        className={styles.regionToggle}
      >
        <ChevronRight
          className={`${styles.regionChevron} ${isOpen ? styles.regionChevronOpen : ""}`}
        />

        <span className={styles.regionName}>{regionName || "Unnamed region"}</span>

        <span className={styles.regionMeta}>
          Map {mapId} · {tiles.length} {tiles.length === 1 ? "tile" : "tiles"}
        </span>
      </button>

      {isOpen && (
        <div className={styles.regionTiles}>
          {sortedTiles.map((tile) => (
            <span
              key={`${tile.mapTileX}-${tile.mapTileY}`}
              className={styles.tileMarker}
              title={`Tile (${tile.mapTileX}, ${tile.mapTileY})`}
            />
          ))}
        </div>
      )}
    </figure>
  )
}