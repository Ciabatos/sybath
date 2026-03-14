"use client"

import { Button } from "@/components/ui/button"
import {
  Anchor,
  Box,
  Crown,
  Eye,
  Gem,
  Lock,
  Package,
  Scroll,
  Shield,
  Sparkles,
  Star,
  Sword,
  Target,
  Wind,
} from "lucide-react"
import { useState } from "react"
import { GiFizzingFlask, GiHearts, GiPiercingSword, GiShield } from "react-icons/gi"
import styles from "./styles/ItemDetail.module.css"

type RarityColors = {
  common: string
  uncommon: string
  rare: string
  epic: string
  legendary: string
}

export default function ItemDetail() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [isExpanded, setIsExpanded] = useState<boolean>(false)
  const [showTooltip, setShowTooltip] = useState<string | null>(null)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    itemId: "item_001",
    itemName: "Blade of the Fallen King",
    rarity: "legendary",
    type: "Weapon",
    subType: "Sword",
    description:
      "A legendary blade forged in the fires of ancient battle, this sword once belonged to a king who fell defending his realm.",
    loreText:
      "The blade hums with power when held by worthy hands. Legends say it was tempered in dragon's breath and blessed by the gods themselves. Its edge never dulls, for it is said to be forged from the very essence of victory.",
    abilities: [
      { abilityName: "Dragon's Breath", abilityDescription: "Deals additional fire damage on critical hits" },
      { abilityName: "Royal Authority", abilityDescription: "Intimidates enemies, reducing their attack power by 15%" },
      { abilityName: "Unyielding Edge", abilityDescription: "Cannot be broken or damaged in any way" },
    ],
    properties: {
      isEnchanted: true,
      isCursed: false,
      isUnique: true,
    },
    stats: [
      { statName: "Attack Power", value: "+150", isPositive: true },
      { statName: "Critical Chance", value: "+25%", isPositive: true },
      { statName: "Speed", value: "-10%", isPositive: false },
      { statName: "Defense", value: "+15", isPositive: true },
    ],
    levelRequirement: 45,
    weight: 8.5,
    slotType: "MainHand",
    sellValue: 2500,
    isEquipable: true,
    qualityLevel: 5,
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const rarityColors = {
    common: "#9CA3AF",
    uncommon: "#10B981",
    rare: "#3B82F6",
    epic: "#A855F7",
    legendary: "#D4AF37",
  }

  const rarityGlow = {
    common: "",
    uncommon: "",
    rare: "box-shadow: 0 0 10px #3B82F6;",
    epic: "box-shadow: 0 0 15px #A855F7, inset 0 0 10px rgba(168, 85, 247, 0.3);",
    legendary: "box-shadow: 0 0 20px #D4AF37, inset 0 0 15px rgba(212, 175, 55, 0.4);",
  }

  const qualityColors = ["#6B7280", "#9CA3AF", "#D4AF37", "#A855F7", "#FFD700"]

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleEquip() {
    console.log("Equipping item:", MOCK.itemName)
  }

  function handleInspectFullDetails() {
    setIsExpanded(!isExpanded)
  }

  function handleSellItem() {
    console.log("Selling item for", MOCK.sellValue, "gold")
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.container}>
      {/* HEADER */}
      <div className={`${styles.header} ${rarityGlow[MOCK.rarity as keyof RarityColors]}`}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>{MOCK.itemName}</h2>

          <div className={styles.badgesContainer}>
            {/* Rarity Badge */}
            <span
              className={`${styles.rarityBadge} ${styles[MOCK.rarity]}`}
              style={{
                background: `linear-gradient(135deg, ${rarityColors[MOCK.rarity as keyof RarityColors]}, ${rarityColors[MOCK.rarity as keyof RarityColors]})`,
              }}
            >
              {MOCK.rarity === "legendary" && <Sparkles className={styles.rarityIcon} />}
              {MOCK.rarity === "epic" && <Star className={styles.rarityIcon} />}
              {MOCK.rarity === "rare" && <Gem className={styles.rarityIcon} />}
              {MOCK.rarity === "uncommon" && <Crown className={styles.rarityIcon} />}
              {MOCK.rarity === "common" && <Box className={styles.rarityIcon} />}
            </span>

            {/* Type Badge */}
            <span className={`${styles.typeBadge}`}>
              {MOCK.type === "Weapon" && <Sword className={styles.badgeIcon} />}
              {MOCK.type === "Armor" && <Shield className={styles.badgeIcon} />}
              {MOCK.type === "Consumable" && <GiFizzingFlask className={styles.badgeIcon} />}
              {MOCK.type === "Accessory" && <Anchor className={styles.badgeIcon} />}
              {MOCK.type}
            </span>

            {/* Level Requirement */}
            {MOCK.levelRequirement > 0 && (
              <span className={`${styles.requirementBadge}`}>
                <Lock className={styles.badgeIcon} />
                Lvl {MOCK.levelRequirement}
              </span>
            )}

            {/* Weight/Slot Info */}
            <span className={`${styles.infoBadge}`}>
              <Package className={styles.badgeIcon} />
              {MOCK.weight}kg · {MOCK.slotType}
            </span>
          </div>
        </div>

        {/* Quality Indicator Bar */}
        <div className={styles.qualityBarContainer}>
          <div className={styles.qualityBar}>
            {[...Array(5)].map((_, index) => (
              <div
                key={index}
                className={`${styles.qualitySegment} ${index < MOCK.qualityLevel ? styles.qualityFilled : ""}`}
                style={{ background: qualityColors[MOCK.qualityLevel - 1] || "#6B7280" }}
              />
            ))}
          </div>
        </div>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Stats Grid */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Item Statistics</h3>
          <div className={styles.statsGrid}>
            {MOCK.stats.map(function (stat) {
              return (
                <div
                  key={stat.statName}
                  className={`${styles.statCard} ${stat.isPositive ? styles.positiveStat : ""}`}
                  onMouseEnter={() => setShowTooltip(stat.statName)}
                  onMouseLeave={() => setShowTooltip(null)}
                >
                  <div className={styles.statIconContainer}>
                    {stat.statName.includes("Attack") && <GiPiercingSword className={styles.statIcon} />}
                    {stat.statName.includes("Defense") && <GiShield className={styles.statIcon} />}
                    {stat.statName.includes("Health") && <GiHearts className={styles.statIcon} />}
                    {stat.statName.includes("Mana") && <GiFizzingFlask className={styles.statIcon} />}
                    {stat.statName.includes("Speed") && <Wind className={styles.statIcon} />}
                    {stat.statName.includes("Critical") && <Target className={styles.statIcon} />}
                  </div>
                  <div className={styles.statInfo}>
                    <span className={styles.statLabel}>{stat.statName}</span>
                    <span
                      className={`${styles.statValue} ${stat.isPositive ? styles.positive : ""}`}
                      style={{ color: stat.isPositive ? "#10B981" : "#EF4444" }}
                    >
                      {stat.value}
                    </span>
                  </div>
                </div>
              )
            })}
          </div>
        </section>

        {/* Description Section */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Description</h3>
          <p className={styles.descriptionText}>{MOCK.description}</p>

          {MOCK.loreText && (
            <div className={styles.loreContainer}>
              <Scroll className={styles.loreIcon} />
              <p className={styles.loreText}>{MOCK.loreText}</p>
            </div>
          )}

          {/* Special Abilities */}
          {MOCK.abilities.length > 0 && (
            <div className={styles.abilitiesContainer}>
              <h4 className={styles.sectionTitleSmall}>Special Abilities</h4>
              <div className={styles.abilitiesGrid}>
                {MOCK.abilities.map(function (ability) {
                  return (
                    <div
                      key={ability.abilityName}
                      className={styles.abilityCard}
                    >
                      <Sparkles className={styles.abilityIcon} />
                      <span className={styles.abilityName}>{ability.abilityName}</span>
                      <span className={styles.abilityDescription}>{ability.abilityDescription}</span>
                    </div>
                  )
                })}
              </div>
            </div>
          )}

          {/* Properties */}
          {Object.values(MOCK.properties).some(Boolean) && (
            <div className={styles.propertiesContainer}>
              <h4 className={styles.sectionTitleSmall}>Properties</h4>
              <div className={styles.propertiesGrid}>
                {MOCK.properties.isEnchanted && (
                  <span
                    className={`${styles.propertyBadge} ${styles.enchanted}`}
                    onMouseEnter={() => setShowTooltip("This item is enchanted with magical properties")}
                    onMouseLeave={() => setShowTooltip(null)}
                  >
                    <Sparkles className={styles.propertyIcon} />
                    Enchanted
                  </span>
                )}
                {MOCK.properties.isCursed && (
                  <span
                    className={`${styles.propertyBadge} ${styles.cursed}`}
                    onMouseEnter={() => setShowTooltip("This item is cursed and may cause misfortune")}
                    onMouseLeave={() => setShowTooltip(null)}
                  >
                    <Lock className={styles.propertyIcon} />
                    Cursed
                  </span>
                )}
                {MOCK.properties.isUnique && (
                  <span
                    className={`${styles.propertyBadge} ${styles.unique}`}
                    onMouseEnter={() => setShowTooltip("This is a unique item with special properties")}
                    onMouseLeave={() => setShowTooltip(null)}
                  >
                    <Crown className={styles.propertyIcon} />
                    Unique
                  </span>
                )}
              </div>
            </div>
          )}
        </section>

        {/* Action Footer */}
        <footer className={styles.footer}>
          {MOCK.isEquipable && (
            <Button
              className={`${styles.actionButton} ${styles.equipButton}`}
              onClick={handleEquip}
            >
              <GiShield className={styles.buttonIcon} />
              Equip Item
            </Button>
          )}

          <Button
            className={`${styles.actionButton} ${styles.inspectButton}`}
            variant='outline'
            onClick={handleInspectFullDetails}
          >
            <Eye className={styles.buttonIcon} />
            {isExpanded ? "Hide Details" : "Show Full Details"}
          </Button>

          <div className={styles.sellValueContainer}>
            <span className={styles.sellLabel}>Sell Value:</span>
            <span className={styles.sellAmount}>{MOCK.sellValue} gp</span>
          </div>
        </footer>
      </div>
    </div>
  )
}
