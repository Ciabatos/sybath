"use client"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { Crown, Gem, Sparkles } from "lucide-react"
import { useState } from "react"

import { GiMagicShield, GiShield, GiSwordWound } from "react-icons/gi"
import { MdBatteryCharging20, MdBatteryCharging30, MdBatteryCharging50, MdBatteryCharging90 } from "react-icons/md"
import styles from "./styles/ItemDetail.module.css"
export default function ItemDetail() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [isHovered, setIsHovered] = useState<boolean>(false)
  const [selectedStat, setSelectedStat] = useState<string | null>(null)
  const [showEnchantDetails, setShowEnchantDetails] = useState<boolean>(false)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    itemName: "Dragonbane Longsword",
    itemDescription:
      "A legendary blade forged in the fires of Mount Doom. The dragon's scales crumble before its edge, and ancient runes glow with power when darkness approaches.",
    itemStats: {
      strength: 45,
      defense: 12,
      magicPower: 89,
      speed: 34,
      vitality: 28,
    },
    itemRarity: "legendary",
    levelRequirement: 42,
    itemIconUrl: null,
    itemType: "weapon",
    enchantmentLevel: 5,
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const rarityColors = {
    common: "#9CA3AF",
    rare: "#10B981",
    epic: "#8B5CF6",
    legendary: "#F59E0B",
    mythic: "#EF4444",
  }

  const rarityIcons = {
    common: MdBatteryCharging20,
    rare: MdBatteryCharging90,
    epic: MdBatteryCharging30,
    legendary: MdBatteryCharging50,
    mythic: Crown,
  }

  const statLabels = {
    strength: "Strength",
    defense: "Defense",
    magicPower: "Magic Power",
    speed: "Speed",
    vitality: "Vitality",
  }

  const statIcons = {
    strength: <GiSwordWound />,
    defense: <GiShield />,
    magicPower: <GiMagicShield />,
    speed: <Sparkles />,
    vitality: <Gem />,
  }

  const getRarityColor = (rarity: string) => rarityColors[rarity as keyof typeof rarityColors] || "#9CA3AF"

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleStatClick(statKey: string) {
    setSelectedStat(selectedStat === statKey ? null : statKey)
  }

  function handleEnchantToggle() {
    setShowEnchantDetails(!showEnchantDetails)
  }

  function handleEquip() {
    console.log("Equipping item:", MOCK.itemName)
  }

  function handleInspect() {
    console.log("Inspecting item details")
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.container}>
      {/* HEADER */}
      <div className={styles.header}>
        <h2 className={styles.title}>{MOCK.itemName}</h2>
        <p className={styles.subTitle}>{statLabels[MOCK.itemType as keyof typeof statLabels]}</p>
        <span className={styles.rarityBadge}>
          {rarityIcons[MOCK.itemRarity]}
          <span className={styles.rarityText}>{MOCK.itemRarity.toUpperCase()}</span>
        </span>
      </div>

      {/* CONTENT */}
      <ScrollArea className={styles.scrollArea}>
        <div className={styles.content}>
          {/* Item Icon & Basic Info */}
          <section className={styles.section}>
            <div className={styles.itemIconContainer}>
              {MOCK.itemIconUrl ? (
                <img
                  src={MOCK.itemIconUrl}
                  alt={MOCK.itemName}
                  className={styles.itemIcon}
                />
              ) : (
                <div className={`${styles.itemIconPlaceholder} ${styles[`itemIcon_${MOCK.itemType}`]}`}>
                  {statIcons[MOCK.itemType as keyof typeof statIcons]}
                </div>
              )}
            </div>
            <div className={styles.basicInfo}>
              <Badge
                variant='outline'
                className={styles.typeBadge}
              >
                {MOCK.itemType.toUpperCase()}
              </Badge>
              <span className={styles.enchantLevel}>Enchantment Lvl {MOCK.enchantmentLevel}</span>
            </div>
          </section>

          {/* Description */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Description</h3>
            <p className={styles.description}>{MOCK.itemDescription}</p>
          </section>

          {/* Stats Grid */}
          <section className={styles.section}>
            <div className={styles.statsHeader}>
              <h3 className={styles.sectionTitle}>Statistics</h3>
              <span className={styles.levelReq}>Level {MOCK.levelRequirement}+</span>
            </div>
            <div className={styles.statsGrid}>
              {(Object.keys(MOCK.itemStats) as Array<keyof typeof MOCK.itemStats>).map(function (statKey, index) {
                const statValue = MOCK.itemStats[statKey]
                return (
                  <div
                    key={statKey}
                    className={`${styles.statRow} ${selectedStat === statKey ? styles.selected : ""}`}
                    onMouseEnter={() => setIsHovered(true)}
                    onMouseLeave={() => setIsHovered(false)}
                    onClick={() => handleStatClick(statKey)}
                  >
                    <div className={styles.statIconContainer}>{statIcons[statKey]}</div>
                    <span className={styles.statLabel}>{statLabels[statKey]}</span>
                    <span className={`${styles.statValue} ${selectedStat === statKey ? styles.selectedText : ""}`}>
                      {statValue}
                    </span>
                  </div>
                )
              })}
            </div>
          </section>

          {/* Enchantment Details */}
          <section className={styles.section}>
            <Button
              variant='ghost'
              size='sm'
              onClick={handleEnchantToggle}
              className={styles.enchantButton}
            >
              {showEnchantDetails ? "Hide Enchantments" : "View Enchantments"}
              <Sparkles />
            </Button>
            {showEnchantDetails && (
              <div className={styles.enchantmentContainer}>
                <h4 className={styles.enchantmentTitle}>Active Enchantments</h4>
                <div className={styles.enchantmentList}>
                  <div className={styles.enchantmentItem}>
                    <span className={styles.enchantmentIcon}>⚔️</span>
                    <span className={styles.enchantmentName}>Sharpness</span>
                    <span className={styles.enchantmentValue}>+15% Damage</span>
                  </div>
                  <div className={styles.enchantmentItem}>
                    <span className={styles.enchantmentIcon}>🛡️</span>
                    <span className={styles.enchantmentName}>Fortification</span>
                    <span className={styles.enchantmentValue}>+8% Defense</span>
                  </div>
                  <div className={styles.enchantmentItem}>
                    <span className={styles.enchantmentIcon}>✨</span>
                    <span className={styles.enchantmentName}>Arcane Warding</span>
                    <span className={styles.enchantmentValue}>+12 Magic Power</span>
                  </div>
                </div>
              </div>
            )}
          </section>

          {/* Action Buttons */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Actions</h3>
            <div className={styles.actionButtons}>
              <Button
                onClick={handleEquip}
                variant='default'
                className={styles.actionButton}
              >
                Equip Item
              </Button>
              <Button
                onClick={handleInspect}
                variant='outline'
                className={styles.actionButton}
              >
                Inspect Details
              </Button>
            </div>
          </section>

          {/* Footer Info */}
          <section className={styles.section}>
            <Separator />
            <div className={styles.footerInfo}>
              <span className={styles.footerLabel}>Item ID:</span>
              <span className={styles.footerValue}>ITEM_{MOCK.itemName.replace(/\s+/g, "_").toUpperCase()}</span>
              <span className={styles.footerLabel}>Owner:</span>
              <span className={styles.footerValue}>Player</span>
            </div>
          </section>
        </div>
      </ScrollArea>

      {/* Hover Effects */}
      {isHovered && (
        <div className={styles.hoverOverlay}>
          <div className={styles.rarityGlow}>{rarityIcons[MOCK.itemRarity]}</div>
        </div>
      )}
    </div>
  )
}
