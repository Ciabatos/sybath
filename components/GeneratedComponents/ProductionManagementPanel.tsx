"use client"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Activity, AlertCircle, ChevronRight, Settings, Zap } from "lucide-react"
import { useState } from "react"
import { FaUsers } from "react-icons/fa"
import { GiCastle, GiCheckMark, GiCircleCage, GiHammerNails, GiWheat } from "react-icons/gi"
import { IoIosTrendingUp } from "react-icons/io"
import { LuPickaxe } from "react-icons/lu"
import styles from "./styles/ProductionManagementPanel.module.css"

export default function ProductionManagementPanel() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [selectedBuilding, setSelectedBuilding] = useState<string>("farm")
  const [isOptimalEfficiency, setIsOptimalEfficiency] = useState<boolean>(false)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    buildings: [
      { id: "1", type: "farm", name: "Royal Granary Farm" },
      { id: "2", type: "mine", name: "Iron Vein Mine" },
      { id: "3", type: "quarry", name: "Stone Quarry" },
      { id: "4", type: "granary", name: "King's Granary" },
    ],

    buildingStats: {
      farm: {
        productionCapacity: 100,
        currentProductionRate: 75,
        maxProductionRate: 120,
        workerCount: 8,
        maxWorkers: 12,
        productionTimeHours: 6,
        resourceOutput: { type: "Wheat", amount: 45 },
        efficiencyLevel: "high",
        isProducing: true,
        progressPercentage: 75,
      },
      mine: {
        productionCapacity: 80,
        currentProductionRate: 60,
        maxProductionRate: 100,
        workerCount: 6,
        maxWorkers: 10,
        productionTimeHours: 4,
        resourceOutput: { type: "Iron Ore", amount: 32 },
        efficiencyLevel: "medium",
        isProducing: true,
        progressPercentage: 60,
      },
      quarry: {
        productionCapacity: 90,
        currentProductionRate: 45,
        maxProductionRate: 110,
        workerCount: 4,
        maxWorkers: 8,
        productionTimeHours: 8,
        resourceOutput: { type: "Stone", amount: 28 },
        efficiencyLevel: "low",
        isProducing: false,
        progressPercentage: 0,
      },
      granary: {
        productionCapacity: 150,
        currentProductionRate: 90,
        maxProductionRate: 180,
        workerCount: 12,
        maxWorkers: 16,
        productionTimeHours: 3,
        resourceOutput: { type: "Grain", amount: 75 },
        efficiencyLevel: "optimal",
        isProducing: true,
        progressPercentage: 90,
      },
    },

    totalProduction: { farm: 12450, mine: 8320, quarry: 6780, granary: 15600 },
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const selectedBuildingStats = MOCK.buildingStats[selectedBuilding]

  const efficiencyColors = {
    low: "#8B0000",
    medium: "#D2691E",
    high: "#C0C0C0",
    optimal: "#FFD700",
  }

  const workerPercentage =
    selectedBuildingStats.maxWorkers === 0
      ? 0
      : Math.round((selectedBuildingStats.workerCount / selectedBuildingStats.maxWorkers) * 100)

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleSelectBuilding(type: string) {
    setSelectedBuilding(type)
  }

  function handleAddWorker() {
    console.log("Adding worker to production")
  }

  function handleRemoveWorker() {
    console.log("Removing worker from production")
  }

  function handleToggleProduction() {
    console.log("Toggling production state")
  }

  function handleOptimizeEfficiency() {
    setIsOptimalEfficiency(true)
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <h2 className={styles.title}>Production Management</h2>
        <p className={styles.subTitle}>Castle Resource Control Panel</p>
        <span className={styles.coordinates}>[Sector 7 · Castle Keep]</span>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Building Selector Tab */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Building Selection</h3>
          <Tabs
            value={selectedBuilding}
            onValueChange={handleSelectBuilding}
          >
            <TabsList className={styles.tabsList}>
              {MOCK.buildings.map(function (building) {
                return (
                  <TabsTrigger
                    key={building.id}
                    value={building.type}
                    className={styles.tabTrigger}
                  >
                    {building.name}
                  </TabsTrigger>
                )
              })}
            </TabsList>

            {/* Building Card */}
            <TabsContent
              value={selectedBuilding}
              className={styles.tabsContent}
            >
              <Card className={styles.buildingCard}>
                <div className={styles.cardHeader}>
                  <GiCastle className={styles.cardIcon} />
                  <h3 className={styles.cardTitle}>{MOCK.buildings.find((b) => b.type === selectedBuilding)?.name}</h3>
                  <Badge
                    variant='outline'
                    className={styles.buildingType}
                  >
                    {selectedBuilding.toUpperCase()}
                  </Badge>
                </div>

                {/* Production Stats Summary */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Production Capacity</h4>
                  <div className={styles.statsGrid}>
                    <div className={styles.statItem}>
                      <IoIosTrendingUp className={styles.statIcon} />
                      <span className={styles.statLabel}>Current Rate</span>
                      <span className={styles.statValue}>{selectedBuildingStats.currentProductionRate}</span>
                      <span className={styles.statUnit}>/hr</span>
                    </div>
                    <div className={styles.statItem}>
                      <IoIosTrendingUp className={styles.statIcon} />
                      <span className={styles.statLabel}>Max Rate</span>
                      <span className={styles.statValue}>{selectedBuildingStats.maxProductionRate}</span>
                      <span className={styles.statUnit}>/hr</span>
                    </div>
                  </div>
                </section>

                {/* Worker Control Panel */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Worker Management</h4>
                  <div className={styles.workerControlPanel}>
                    <div className={styles.workerInfo}>
                      <FaUsers className={styles.workerIcon} />
                      <span className={styles.workerLabel}>
                        {selectedBuildingStats.workerCount} / {selectedBuildingStats.maxWorkers} Workers
                      </span>
                      <span className={styles.workerPercentage}>{workerPercentage}%</span>
                    </div>

                    <div className={styles.workerControls}>
                      <Button
                        className={styles.workerButton}
                        onClick={handleAddWorker}
                        disabled={selectedBuildingStats.workerCount >= selectedBuildingStats.maxWorkers}
                      >
                        <FaUsers className={styles.buttonIcon} /> Add Worker
                      </Button>
                      <Button
                        className={styles.workerButton}
                        onClick={handleRemoveWorker}
                        disabled={selectedBuildingStats.workerCount <= 1}
                      >
                        <AlertCircle className={styles.buttonIcon} /> Remove Worker
                      </Button>
                    </div>
                  </div>
                </section>

                {/* Resource Output Indicator */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Resource Output</h4>
                  <div className={styles.resourceOutputContainer}>
                    {selectedBuildingStats.resourceOutput.type === "Wheat" && (
                      <GiWheat className={styles.resourceIcon} />
                    )}
                    {selectedBuildingStats.resourceOutput.type === "Iron Ore" && (
                      <LuPickaxe className={styles.resourceIcon} />
                    )}
                    {selectedBuildingStats.resourceOutput.type === "Stone" && (
                      <GiHammerNails className={styles.resourceIcon} />
                    )}
                    {selectedBuildingStats.resourceOutput.type === "Grain" && (
                      <GiCastle className={styles.resourceIcon} />
                    )}

                    <div className={styles.resourceInfo}>
                      <span className={styles.resourceName}>{selectedBuildingStats.resourceOutput.type}</span>
                      <span className={styles.resourceAmount}>{selectedBuildingStats.resourceOutput.amount}</span>
                    </div>

                    <Badge
                      variant='outline'
                      className={styles.productionTime}
                    >
                      {selectedBuildingStats.productionTimeHours}h cycle
                    </Badge>
                  </div>
                </section>

                {/* Efficiency Meter */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Efficiency Level</h4>
                  <div className={styles.efficiencyContainer}>
                    {selectedBuildingStats.efficiencyLevel === "low" && (
                      <GiCircleCage className={styles.efficiencyIcon} />
                    )}
                    {selectedBuildingStats.efficiencyLevel === "medium" && (
                      <Activity className={styles.efficiencyIcon} />
                    )}
                    {selectedBuildingStats.efficiencyLevel === "high" && <Zap className={styles.efficiencyIcon} />}
                    {selectedBuildingStats.efficiencyLevel === "optimal" && (
                      <GiCheckMark className={styles.efficiencyIcon} />
                    )}

                    <span className={styles.efficiencyLabel}>
                      {selectedBuildingStats.efficiencyLevel.toUpperCase()}
                    </span>
                    <Progress
                      value={workerPercentage}
                      className={styles.efficiencyBar}
                    />
                  </div>
                </section>

                {/* Production Cycle Timer */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Production Status</h4>
                  <div className={styles.productionStatusContainer}>
                    {selectedBuildingStats.isProducing ? (
                      <>
                        <GiHammerNails className={styles.statusIcon} />
                        <span className={styles.statusText}>Currently Producing</span>
                        <Badge
                          variant='outline'
                          className={styles.statusBadge}
                        >
                          {Math.round(selectedBuildingStats.progressPercentage)}% Complete
                        </Badge>
                      </>
                    ) : (
                      <>
                        <AlertCircle className={styles.statusIcon} />
                        <span className={styles.statusText}>Production Paused</span>
                        <Button
                          className={styles.resumeButton}
                          onClick={handleToggleProduction}
                        >
                          Resume Production
                        </Button>
                      </>
                    )}
                  </div>

                  {/* Progress Bar */}
                  {selectedBuildingStats.isProducing && (
                    <Progress
                      value={selectedBuildingStats.progressPercentage}
                      className={styles.productionBar}
                    />
                  )}
                </section>

                {/* Optimization Controls */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Optimization</h4>
                  <div className={styles.optimizationControls}>
                    <Button
                      className={styles.optimizeButton}
                      onClick={handleOptimizeEfficiency}
                      variant='outline'
                    >
                      <Settings className={styles.buttonIcon} /> Optimize Efficiency
                    </Button>
                    <Badge
                      className={styles.efficiencyBadge}
                      style={{ backgroundColor: selectedBuildingStats.efficiencyLevel }}
                    >
                      {selectedBuildingStats.efficiencyLevel.toUpperCase()}
                    </Badge>
                  </div>
                </section>

                {/* Total Production Stats */}
                <section className={styles.section}>
                  <h4 className={styles.sectionTitle}>Total Castle Production</h4>
                  <div className={styles.totalProductionContainer}>
                    {MOCK.buildings.map(function (building) {
                      return (
                        <div
                          key={building.id}
                          className={styles.productionItem}
                        >
                          <span className={styles.productionLabel}>{building.name}</span>
                          <span className={styles.productionValue}>{selectedBuildingStats.totalProduction}</span>
                        </div>
                      )
                    })}
                  </div>
                </section>

                {/* Action Buttons */}
                <div className={styles.actionButtons}>
                  <Button
                    className={styles.actionButton}
                    onClick={() => console.log("View detailed reports")}
                  >
                    View Reports <ChevronRight className={styles.buttonIcon} />
                  </Button>
                  <Button
                    className={styles.actionButton}
                    variant='outline'
                    onClick={() => console.log("Adjust building settings")}
                  >
                    Adjust Settings <Settings className={styles.buttonIcon} />
                  </Button>
                </div>
              </Card>
            </TabsContent>
          </Tabs>
        </section>

        {/* Hints */}
        {isOptimalEfficiency && (
          <p className={styles.hintText}>Production efficiency optimized! Maximum output achieved.</p>
        )}

        {!selectedBuildingStats.isProducing && (
          <div className={styles.emptyState}>
            <AlertCircle className={styles.emptyStateIcon} />
            <p>Select a building to begin production management</p>
          </div>
        )}
      </div>
    </div>
  )
}
