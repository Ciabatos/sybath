import { createImage } from "@/methods/functions/util/createImage"
import { TMapTile } from "@/methods/hooks/world/composite/useMapHandling"
import { Users } from "lucide-react"
import styles from "./styles/TileLayerHeroes.module.css"

type TProps = {
  tile: TMapTile
  /** true = aktywna warstwa szczegółowa. false = zlicznik z ikoną grupy. */
  showDetail: boolean
}

/** Ile portretów mieści się w rzędzie, zanim pozostaną same ramki. */
const MAX_DETAIL_ROW = 4

// `createImage` jest czyste — wywołanie raz na moduł, nie na każdy kafelek.
const { createPlayerImage, createSquadImage } = createImage()

/**
 * Bohaterowie na kafelku — przełączana warstwa.
 *
 * Baza (warstwa wyłączona) → jedna liczba i jedna ikona `Users`, czyli
 * „tu są jacyś bohaterowie". Bez portretów, bo kafelek ma 64px.
 *
 * Warstwa włączona → ta sama liczba PLUS portret każdego bohatera w rzędzie
 * na dole kafelka, żeby było widać kto konkretnie.
 */
export default function TileLayerHeroes({ tile, showDetail }: TProps) {
  const otherPlayers = tile.knownPlayersPositions?.otherPlayers ?? []

  if (otherPlayers.length === 0) return null

  const count = otherPlayers.length

  return (
    <>
      <span
        className={styles.badge}
        title={`${count} ${count === 1 ? "hero" : "heroes"} on this tile`}
      >
        <Users className={styles.badgeIcon} />
        <span className={styles.badgeValue}>{count}</span>
      </span>

      {showDetail && (
        <span className={styles.row}>
          {otherPlayers.map((other, index) => (
            <span
              key={other.otherPlayerId}
              className={styles.rowMarker}
              /* Po MAX_DETAIL_ROW portret znika, zostaje ramka — liczba
                 graczy wciąż czytelna, kafelek się nie rozjeżdża. */
              data-collapsed={index >= MAX_DETAIL_ROW}
              data-squad={other.inSquad}
              style={{
                backgroundImage: other.inSquad ? createSquadImage(other.imageMap) : createPlayerImage(other.imageMap),
              }}
            />
          ))}
        </span>
      )}
    </>
  )
}