"use client"

import GatherResource from "@/components/items/GatherResource"
import ExploreButtonCancel from "@/components/map/ExploreButtonCancel"
import ExploreButtonConfirm from "@/components/map/ExploreButtonConfirm"
import ExploreButtonPlan from "@/components/map/ExploreButtonPlan"
import MoveButtonCancel from "@/components/map/MoveButtonCancel"
import MoveButtonConfirm from "@/components/map/MoveButtonConfirm"
import MoveButtonPlan from "@/components/map/MoveButtonPlan"
import { Button } from "@/components/ui/button"
import { Progress } from "@/components/ui/progress"
import getIcon from "@/methods/functions/icons/getIcon"
import { useModalBottomLeft } from "@/methods/hooks/modals/useModalBottomLeft"
import { useModalRightCenter } from "@/methods/hooks/modals/useModalRightCenter"
import { usePlayerExploration } from "@/methods/hooks/players/composite/usePlayerExploration"
import { usePlayerMovement } from "@/methods/hooks/players/composite/usePlayerMovement"
import { useMapTileActions } from "@/methods/hooks/world/composite/useMapTileActions"
import { TMapTileResource, useMapTileDetail } from "@/methods/hooks/world/composite/useMapTileDetail"
import { EPanelsBottomLeft } from "@/types/enumeration/EPanelsBottomLeft"
import { Backpack, Compass, Footprints, MapPin, Swords, Tent, Users, X } from "lucide-react"
import { Activity, useEffect, useState } from "react"
import styles from "./styles/MapTileDetail.module.css"

/** Ikona zastępcza, gdy getIcon nie zna klucza obrazu przedmiotu. */
const FALLBACK_ICON = "📦"

export default function MapTileDetail() {
  const { resetModalRightCenter } = useModalRightCenter()
  const { openModalBottomLeft } = useModalBottomLeft()
  const { clickedMapTile } = useMapTileActions()

  const { isMoving } = usePlayerMovement()
  const { isExploring } = usePlayerExploration()

  const { combinedKnownMapTilesResourcesOnTile } = useMapTileDetail()
  const [clickedResource, setClickedResource] = useState<TMapTileResource | null>(null)

  useEffect(() => {
    setClickedResource(null)
  }, [clickedMapTile])

  if (!clickedMapTile) {
    return null
  }

  const onClose = () => {
    resetModalRightCenter()
  }

  function handlePlayersListOnTile() {
    openModalBottomLeft(EPanelsBottomLeft.PlayersOnTile)
  }

  function handleResourceOnTile(resource: TMapTileResource) {
    setClickedResource(resource)
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const { mapTiles, terrainTypes, landscapeTypes, cities, districts, districtTypes } = clickedMapTile

  const terrainName = terrainTypes?.name
  const landscapeName = landscapeTypes?.name
  const cityName = cities?.name
  const districtName = districts?.name
  const districtTypeName = districtTypes?.name

  const totalMoveCost =
    (terrainTypes?.moveCost || 0) + (landscapeTypes?.moveCost || 0) + (cities?.moveCost || 0) + (districtTypes?.moveCost || 0)

  const allResources = combinedKnownMapTilesResourcesOnTile ?? []
  const foundResources = allResources.filter((resource) => resource.itemId !== null)
  const exploredPercent = allResources.length === 0 ? 100 : Math.round((foundResources.length / allResources.length) * 100)

  const pendingActions = [
    { key: "place", label: "Special Place" },
    { key: "camp", label: "Camp" },
    { key: "hunt", label: "Hunt" },
  ]

  return (
    <div className={styles.overlay}>
      <Activity mode={!!clickedResource ? "visible" : "hidden"}>
        <GatherResource
          onClose={() => setClickedResource(null)}
          resource={clickedResource}
        />
      </Activity>

      <div className={styles.panel}>
        <header className={styles.header}>
          <div className={styles.titleSection}>
            <h2 className={styles.title}>{terrainName ?? "Unknown terrain"}</h2>

            <span className={styles.subLine}>
              {landscapeName && <span className={styles.subLineName}>{landscapeName}</span>}
              <span className={styles.coordinates}>
                <MapPin className={styles.coordinatesIcon} />
                {mapTiles.x}, {mapTiles.y}
              </span>
            </span>
          </div>

          <Button
            onClick={onClose}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
            aria-label='Close'
          >
            <X className={styles.closeIcon} />
          </Button>
        </header>

        {/* Stała wysokość — kliknięcie innego kafelka nie zmienia rozmiaru panelu */}
        <div className={styles.content}>
          <section className={styles.section}>
            <div
              className={styles.sectionHeader}
              title='Movement cost'
            >
              <Footprints className={styles.sectionIcon} />
              <span className={styles.sectionLabel}>Move</span>
              <span className={styles.sectionValue}>{totalMoveCost}</span>
            </div>
          </section>

          {cityName && (
            <section className={styles.section}>
              <div className={styles.sectionHeader}>
                <Tent className={styles.sectionIcon} />
                <span className={styles.sectionLabel}>Settlement</span>
              </div>
              <div className={styles.chipList}>
                <span className={styles.chip}>{cityName}</span>
              </div>
            </section>
          )}

          {districtName && (
            <section className={styles.section}>
              <div className={styles.sectionHeader}>
                <MapPin className={styles.sectionIcon} />
                <span className={styles.sectionLabel}>District</span>
              </div>
              <div className={styles.chipList}>
                <span className={styles.chip}>
                  {districtName}
                  {districtTypeName && <span className={styles.chipMeta}>{districtTypeName}</span>}
                </span>
              </div>
            </section>
          )}

          <section className={styles.section}>
            <div className={styles.sectionHeader}>
              <Backpack className={styles.sectionIcon} />
              <span className={styles.sectionLabel}>Resources</span>
              <span className={styles.sectionValue}>{foundResources.length}</span>
            </div>

            {foundResources.length === 0 ? (
              <p className={styles.emptyText}>
                {allResources.length === 0 ? "Nothing here" : "Not explored yet"}
              </p>
            ) : (
              <div className={styles.chipList}>
                {foundResources.map((resource) => (
                  <Button
                    key={resource.mapTilesResourceId}
                    className={styles.chipButton}
                    title={resource.description || resource.name}
                    onClick={() => handleResourceOnTile(resource)}
                  >
                    <span className={styles.chipIconBox}>{getIcon(resource.image) ?? FALLBACK_ICON}</span>
                    <span className={styles.chipLabel}>{resource.name}</span>
                  </Button>
                ))}
              </div>
            )}

            <div
              className={styles.progressBlock}
              title='Exploration progress'
            >
              <Compass className={styles.progressIcon} />
              <Progress
                value={exploredPercent}
                className={styles.progressBar}
                aria-label='Exploration progress'
              />
              <span className={styles.progressValue}>{exploredPercent}%</span>
            </div>
          </section>

          <section className={styles.section}>
            <div className={styles.sectionHeader}>
              <Users className={styles.sectionIcon} />
              <span className={styles.sectionLabel}>Here</span>
            </div>
            <Button
              className={styles.inlineButton}
              onClick={handlePlayersListOnTile}
              title='Players on this tile'
            >
              <Users className={styles.inlineButtonIcon} />
              Players
            </Button>
          </section>

          <section className={styles.section}>
            <div className={styles.sectionHeader}>
              <Swords className={styles.sectionIcon} />
              <span className={styles.sectionLabel}>Actions</span>
            </div>

            <div className={styles.actionGroup}>
              <div className={styles.actionGroupRow}>
                {isMoving ? (
                  <>
                    <MoveButtonConfirm />
                    <MoveButtonCancel />
                  </>
                ) : (
                  <MoveButtonPlan />
                )}
              </div>
            </div>

            <div className={styles.actionGroup}>
              <div className={styles.actionGroupRow}>
                {isExploring ? (
                  <>
                    <ExploreButtonConfirm />
                    <ExploreButtonCancel />
                  </>
                ) : (
                  <ExploreButtonPlan />
                )}
              </div>
            </div>

            <div className={styles.actionGroup}>
              {pendingActions.map((action) => (
                <Button
                  key={action.key}
                  className={styles.inlineButton}
                  disabled
                  title='Not implemented yet'
                >
                  {action.label}
                </Button>
              ))}
            </div>
          </section>
        </div>
      </div>
    </div>
  )
}