"use client"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  AlertCircle,
  ArrowRight,
  CheckCircle,
  Clock,
  DollarSign,
  MapPin,
  Navigation,
  Package,
  Shield,
  TrendingUp,
  XCircle,
} from "lucide-react"
import { useState } from "react"
import { GiHorseHead, GiOldWagon, GiShipBow } from "react-icons/gi"
import styles from "./styles/TransportCaravanManager.module.css"

export default function TransportCaravanManager() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [selectedRoute, setSelectedRoute] = useState<string>("route_north")
  const [selectedResources, setSelectedResources] = useState<number[]>([])
  const [transportMethod, setTransportMethod] = useState<"horse" | "wagon" | "ship">("wagon")
  const [insurancePurchased, setInsurancePurchased] = useState<boolean>(false)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    originLocation: {
      id: "1",
      name: "Merchant's Rest",
      coordinates: "[452, 893]",
      resourceTypes: ["grain", "cloth", "wine"],
    },
    destinationLocation: {
      id: "2",
      name: "Dragon's Keep",
      coordinates: "[789, 124]",
      resourceTypes: ["gold", "gems", "spices"],
    },

    availableResources: [
      { id: "grain", name: "Grain", quantity: 50, unit: "sacks", valuePerUnit: 3 },
      { id: "cloth", name: "Fine Cloth", quantity: 25, unit: "rolls", valuePerUnit: 8 },
      { id: "wine", name: "Red Wine", quantity: 10, unit: "barrels", valuePerUnit: 12 },
      { id: "spices", name: "Exotic Spices", quantity: 5, unit: "jars", valuePerUnit: 25 },
    ],

    transportMethods: [
      { type: "horse", speed: 8, capacity: 200, baseCost: 15, riskLevel: "low" as const, icon: GiHorseHead },
      { type: "wagon", speed: 4, capacity: 1000, baseCost: 30, riskLevel: "medium" as const, icon: GiOldWagon },
      { type: "ship", speed: 2, capacity: 5000, baseCost: 80, riskLevel: "high" as const, icon: GiShipBow },
    ],

    routeDistance: 450,
    estimatedTime: 12,

    caravanStats: {
      speedPerHour: 4,
      maxCapacity: 1000,
      baseCost: 30,
      riskLevel: "medium" as const,
    },

    transportationFee: 45,
    insuranceCost: 22,

    activeTransports: [
      {
        id: "1",
        origin: "x",
        destination: "y",
        resources: ["grain"],
        status: "in_transit" as const,
        eta: "3d 6h",
        progress: 45,
      },
      {
        id: "2",
        origin: "x",
        destination: "Coastal Port",
        resources: ["wine"],
        status: "loading" as const,
        eta: "1d 2h",
        progress: 78,
      },
    ],

    deliveryHistory: [
      { date: "2 days ago", profit: 150, success: true, method: "wagon" },
      { date: "5 days ago", profit: -45, success: false, method: "ship" },
      { date: "7 days ago", profit: 320, success: true, method: "horse" },
    ],

    routeRisks: [
      { type: "bandits", probability: 15, severity: "high" as const },
      { type: "weather", probability: 8, severity: "medium" as const },
      { type: "terrain", probability: 5, severity: "low" as const },
    ],

    insuranceOptions: [
      { name: "Basic Protection", cost: 22, coverage: "Bandits only" },
      { name: "Full Coverage", cost: 45, coverage: "All risks including weather & terrain" },
    ],
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const selectedResourceIds = MOCK.availableResources.filter((r) => selectedResources.includes(r.id))
  const totalCargoValue = selectedResourceIds.reduce((sum, id) => {
    return (
      sum +
      (MOCK.availableResources.find((r) => r.id === id)?.valuePerUnit || 0) *
        (MOCK.availableResources.find((r) => r.id === id)?.quantity || 0)
    )
  }, 0)

  const totalCost = MOCK.transportationFee + (insurancePurchased ? MOCK.insuranceCost : 0)
  const estimatedProfit = totalCargoValue - totalCost

  const routeRiskPercentage = MOCK.routeRisks.reduce((sum, risk) => sum + risk.probability, 0)

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleSelectResource(resourceId: number) {
    setSelectedResources((prev) =>
      prev.includes(resourceId) ? prev.filter((id) => id !== resourceId) : [...prev, resourceId],
    )
  }

  function handlePurchaseInsurance() {
    setInsurancePurchased(!insurancePurchased)
  }

  function handleSubmitTransport() {
    console.log("Submitting transport request")
  }

  function handleClose() {
    console.log("Closing transport interface")
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>Caravan Transport</h2>
          <p className={styles.subTitle}>
            {MOCK.originLocation.name} → {MOCK.destinationLocation.name}
          </p>
          <span className={styles.coordinates}>
            {MOCK.routeDistance} miles · Est. {MOCK.estimatedTime} days
          </span>
        </div>
        <Button
          onClick={handleClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <AlertCircle className={styles.closeIcon} />
        </Button>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Route Selection */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Route Selection</h3>
          <Card className={styles.routeCard}>
            <CardContent className={styles.routeContent}>
              <div className={styles.routeVisualizer}>
                <MapPin className={styles.originIcon} />
                <span>{MOCK.originLocation.name}</span>
                <ArrowRight className={styles.routeArrow} />
                <span>{MOCK.destinationLocation.name}</span>
                <MapPin className={styles.destinationIcon} />
              </div>
              <div className={styles.routeStats}>
                <Badge
                  variant='outline'
                  className={styles.riskBadge}
                >
                  {routeRiskPercentage}% Risk
                </Badge>
                <span className={styles.distanceText}>{MOCK.routeDistance} miles</span>
              </div>
            </CardContent>
          </Card>
        </section>

        {/* Cargo Configuration */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Cargo Configuration</h3>
          <Tabs
            defaultValue='all'
            className={styles.tabsContainer}
          >
            <TabsList className={styles.tabsList}>
              <TabsTrigger value='all'>All Resources</TabsTrigger>
              <TabsTrigger value='selected'>Selected ({selectedResourceIds.length})</TabsTrigger>
            </TabsList>
            <TabsContent
              value='all'
              className={styles.tabContent}
            >
              <ScrollArea className={styles.scrollArea}>
                <div className={styles.resourceGrid}>
                  {MOCK.availableResources.map(function (resource) {
                    return (
                      <button
                        key={resource.id}
                        onClick={() => handleSelectResource(resource.id)}
                        className={`${styles.resourceCard} ${selectedResources.includes(resource.id) ? styles.selected : ""}`}
                      >
                        <Package className={styles.resourceIcon} />
                        <div className={styles.resourceInfo}>
                          <span className={styles.resourceName}>{resource.name}</span>
                          <span className={styles.resourceQuantity}>
                            {resource.quantity} {resource.unit}
                          </span>
                        </div>
                        <Badge
                          variant='outline'
                          className={styles.resourceValue}
                        >
                          ${resource.valuePerUnit}/unit
                        </Badge>
                      </button>
                    )
                  })}
                </div>
              </ScrollArea>
            </TabsContent>
          </Tabs>
        </section>

        {/* Caravan Options */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Transport Method</h3>
          <Card className={styles.transportCard}>
            <CardContent className={styles.transportContent}>
              {MOCK.transportMethods.map(function (method) {
                return (
                  <button
                    key={method.type}
                    onClick={() => setTransportMethod(method.type)}
                    className={`${styles.methodOption} ${transportMethod === method.type ? styles.selectedMethod : ""}`}
                  >
                    <div className={styles.methodIcon}>
                      <method.icon />
                    </div>
                    <div className={styles.methodInfo}>
                      <span className={styles.methodName}>{method.type.toUpperCase()}</span>
                      <div className={styles.methodStats}>
                        <span className={styles.stat}>
                          <Clock size={12} /> {method.speed} mph
                        </span>
                        <span className={styles.stat}>
                          <Package size={12} /> {method.capacity}
                        </span>
                      </div>
                    </div>
                    <Badge
                      variant='outline'
                      className={styles.riskLevel}
                    >
                      {method.riskLevel.toUpperCase()} Risk
                    </Badge>
                  </button>
                )
              })}
            </CardContent>
          </Card>
        </section>

        {/* Risk Assessment */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Risk Assessment</h3>
          <Card className={styles.riskCard}>
            <CardContent className={styles.riskContent}>
              {MOCK.routeRisks.map(function (risk) {
                return (
                  <div
                    key={risk.type}
                    className={styles.riskItem}
                  >
                    <AlertCircle
                      className={`${styles.riskIcon} ${risk.severity === "high" ? styles.highRisk : risk.severity === "medium" ? styles.mediumRisk : ""}`}
                    />
                    <span className={styles.riskName}>{risk.type}</span>
                    <div className={styles.riskDetails}>
                      <span className={styles.probability}>{risk.probability}% chance</span>
                      <Badge
                        variant='outline'
                        className={styles.severityBadge}
                      >
                        {risk.severity.toUpperCase()}
                      </Badge>
                    </div>
                  </div>
                )
              })}
            </CardContent>
          </Card>
        </section>

        {/* Insurance Panel */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Insurance Protection</h3>
          <Card className={styles.insuranceCard}>
            <CardContent className={styles.insuranceContent}>
              {MOCK.insuranceOptions.map(function (option) {
                return (
                  <div
                    key={option.name}
                    className={styles.insuranceOption}
                  >
                    <Shield className={styles.insuranceIcon} />
                    <div className={styles.insuranceInfo}>
                      <span className={styles.insuranceName}>{option.name}</span>
                      <span className={styles.insuranceCoverage}>{option.coverage}</span>
                    </div>
                    <Badge
                      variant='outline'
                      className={styles.insuranceCost}
                    >
                      ${option.cost}
                    </Badge>
                  </div>
                )
              })}
              <Button
                onClick={handlePurchaseInsurance}
                className={`${styles.insuranceButton} ${insurancePurchased ? styles.purchased : ""}`}
              >
                {insurancePurchased ? "✓ Insurance Purchased" : "Purchase Insurance"}
              </Button>
            </CardContent>
          </Card>
        </section>

        {/* Fee Calculator */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Fee Breakdown</h3>
          <Card className={styles.feeCard}>
            <CardContent className={styles.feeContent}>
              <div className={styles.feeItem}>
                <DollarSign className={styles.feeIcon} />
                <span>Transportation Fee</span>
                <span>${MOCK.transportationFee}</span>
              </div>
              {insurancePurchased && (
                <div className={styles.feeItem}>
                  <Shield className={styles.feeIcon} />
                  <span>Insurance Premium</span>
                  <span>${MOCK.insuranceCost}</span>
                </div>
              )}
              <Separator className={styles.separator} />
              <div className={styles.feeTotal}>
                <span>Total Cost:</span>
                <span className={styles.totalAmount}>${totalCost}</span>
              </div>
            </CardContent>
          </Card>
        </section>

        {/* Active Transports */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Active Caravans</h3>
          <Tabs
            defaultValue='active'
            className={styles.tabsContainer}
          >
            <TabsList className={styles.tabsList}>
              <TabsTrigger value='active'>In Transit ({MOCK.activeTransports.length})</TabsTrigger>
              <TabsTrigger value='history'>History</TabsTrigger>
            </TabsList>
            <TabsContent
              value='active'
              className={styles.tabContent}
            >
              {MOCK.activeTransports.map(function (transport) {
                return (
                  <Card
                    key={transport.id}
                    className={styles.transportCardActive}
                  >
                    <CardContent className={styles.transportCardContent}>
                      <div className={styles.transportHeader}>
                        <span className={styles.transportStatus}>
                          {transport.status.replace("_", " ").toUpperCase()}
                        </span>
                        <Clock size={16} />
                      </div>
                      <div className={styles.transportRoute}>
                        <MapPin size={14} /> {transport.origin} → <MapPin size={14} /> {transport.destination}
                      </div>
                      <Progress
                        value={transport.progress}
                        className={styles.transportProgress}
                      />
                      <span className={styles.transportETA}>{transport.eta}</span>
                    </CardContent>
                  </Card>
                )
              })}
            </TabsContent>
            <TabsContent
              value='history'
              className={styles.tabContent}
            >
              <ScrollArea className={styles.scrollArea}>
                <div className={styles.historyGrid}>
                  {MOCK.deliveryHistory.map(function (delivery, index) {
                    return (
                      <Card
                        key={index}
                        className={styles.historyCard}
                      >
                        <CardContent className={styles.historyCardContent}>
                          <div className={styles.historyRow}>
                            <span className={styles.historyDate}>{delivery.date}</span>
                            <span
                              className={`${styles.historyProfit} ${delivery.profit > 0 ? styles.profitPositive : ""}`}
                            >
                              ${delivery.profit}
                            </span>
                          </div>
                          <Badge
                            variant='outline'
                            className={styles.historyMethod}
                          >
                            {MOCK.transportMethods.find((m) => m.type === delivery.method)?.type.toUpperCase()}
                          </Badge>
                          <div className={styles.historySuccess}>
                            {delivery.success ? (
                              <CheckCircle className={styles.successIcon} />
                            ) : (
                              <XCircle className={styles.failIcon} />
                            )}
                          </div>
                        </CardContent>
                      </Card>
                    )
                  })}
                </div>
              </ScrollArea>
            </TabsContent>
          </Tabs>
        </section>

        {/* Action Buttons */}
        <div className={styles.actionButtons}>
          <Button
            onClick={handleSubmitTransport}
            disabled={selectedResourceIds.length === 0}
            className={styles.submitButton}
          >
            <Navigation className={styles.buttonIcon} />
            Send Caravan
          </Button>
        </div>

        {/* Profit Summary */}
        {selectedResourceIds.length > 0 && (
          <Card className={styles.profitSummary}>
            <CardContent className={styles.profitContent}>
              <TrendingUp className={styles.profitIcon} />
              <div className={styles.profitInfo}>
                <span className={styles.profitLabel}>Estimated Profit</span>
                <span className={`${styles.profitAmount} ${estimatedProfit > 0 ? styles.profitPositive : ""}`}>
                  ${estimatedProfit}
                </span>
              </div>
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  )
}
