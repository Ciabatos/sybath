"use client"

import { Button } from "@/components/ui/button"
import { Eye, Flame, Gem, Heart, Lock, Shield, Sparkles, Sword, Unlock, X, Zap } from "lucide-react"
import { useState } from "react"
import styles from "./styles/ItemDetailPanel.module.css"

interface ItemStat {
  name: string
  value: number | string
  icon: "sword" | "shield" | "heart" | "bolt" | "sparkles"
  max?: number
}

interface SpecialAbility {
  name: string
  description: string
  icon: string
}

type EquipmentSlot = "main-hand" | "off-hand" | "head" | "chest" | "legs" | "hands" | "feet" | "ring" | "amulet"

interface ItemDetailPanelProps {
  item: {
    id: string
    name: string
    rarity: "common" | "rare" | "epic" | "legendary"
    type: "weapon" | "armor" | "accessory" | "consumable" | "artifact"
    stats: ItemStat[]
    description: string
    lore?: string
    specialAbilities?: SpecialAbility[]
    equipmentSlot?: EquipmentSlot
    iconUrl?: string
  }
  onClose?: () => void
  onEquip?: (itemId: string) => void
}

export default function ItemDetailPanel({ item, onClose = () => {}, onEquip = () => {} }: ItemDetailPanelProps) {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [isHoveringStats, setIsHoveringStats] = useState<boolean>(false)
  const [activeAbilityIndex, setActiveAbilityIndex] = useState<number | null>(null)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    itemId: item.id,
    itemName: item.name,
    itemRarity: item.rarity,
    itemType: item.type,
    statName: item.stats.map((s) => s.name),
    statValue: item.stats.map((s) => s.value),
    statIcon: item.stats.map((s) => s.icon),
    descriptionText: item.description,
    loreText: item.lore || "",
    abilityName: item.specialAbilities?.map((a) => a.name) || [],
    abilityDescription: item.specialAbilities?.map((a) => a.description) || [],
    equipmentSlot: item.equipmentSlot || "main-hand",
    iconUrl: item.iconUrl || "/placeholder-item.png",
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const getRarityColor = () => {
    switch (MOCK.itemRarity) {
      case "common":
        return "#8b4513"
      case "rare":
        return "#c9a227"
      case "epic":
        return "#8b45ff"
      case "legendary":
        return "#dc143c"
      default:
        return "#e0d4b8"
    }
  }

  const getRarityGlow = () => {
    switch (MOCK.itemRarity) {
      case "common":
        return "none"
      case "rare":
        return "0 0 10px #c9a227, inset 0 0 5px rgba(201, 162, 39, 0.3)"
      case "epic":
        return "0 0 15px #8b45ff, inset 0 0 8px rgba(139, 69, 255, 0.3)"
      case "legendary":
        return "0 0 20px #dc143c, 0 0 30px rgba(220, 20, 60, 0.5), inset 0 0 10px rgba(220, 20, 60, 0.3)"
      default:
        return "none"
    }
  }

  const getRarityStars = () => {
    switch (MOCK.itemRarity) {
      case "common":
        return ""
      case "rare":
        return "★".repeat(5)
      case "epic":
        return "★".repeat(6)
      case "legendary":
        return "★".repeat(7)
      default:
        return ""
    }
  }

  const getStatIcon = (iconName: string) => {
    switch (iconName) {
      case "sword":
        return <Sword className={styles.statIcon} />
      case "shield":
        return <Shield className={styles.statIcon} />
      case "heart":
        return <Heart className={styles.statIcon} />
      case "bolt":
        return <Zap className={styles.statIcon} />
      case "sparkles":
        return <Sparkles className={styles.statIcon} />
      default:
        return <Gem className={styles.statIcon} />
    }
  }

  const getAbilityIcon = (iconName: string) => {
    switch (iconName.toLowerCase()) {
      case "fire":
        return <Flame className={styles.abilityIcon} />
      case "lightning":
        return <Zap className={styles.abilityIcon} />
      case "ice":
        return <Gem className={styles.abilityIcon} />
      case "heal":
        return <Heart className={styles.abilityIcon} />
      default:
        return <Sparkles className={styles.abilityIcon} />
    }
  }

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleEquip() {
    onEquip(MOCK.itemId)
  }

  function handleInspect() {
    console.log("Inspecting item:", MOCK.itemId)
  }

  function handleClose() {
    onClose()
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div
      className={`${styles.panel} ${styles[`rarity-${MOCK.itemRarity}`]}`}
      style={{ boxShadow: getRarityGlow() }}
    >
      {/* ITEM HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          {item.iconUrl && (
            <img
              src={item.iconUrl}
              alt={`${item.name} icon`}
              className={styles.itemIcon}
            />
          )}
          <h2 className={styles.title}>{item.name}</h2>
          <div className={styles.rarityBar}>
            {getRarityStars()}
            <span className={styles.rarityText}>{MOCK.itemRarity.toUpperCase()}</span>
          </div>
          <p className={styles.typeLabel}>Type: {MOCK.itemType}</p>
        </div>
      </div>

      {/* STATS GRID */}
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Stats</h3>
        <div
          className={styles.statsGrid}
          onMouseEnter={() => setIsHoveringStats(true)}
          onMouseLeave={() => setIsHoveringStats(false)}
        >
          {item.stats.map((stat, index) => (
            <div
              key={index}
              className={`${styles.statBox} ${styles[`icon-${stat.icon}`]}`}
              style={{
                transform: isHoveringStats ? "translateY(-2px)" : "none",
                boxShadow: isHoveringStats ? `0 0 15px ${getRarityColor()}` : "none",
              }}
            >
              <div className={styles.statIconContainer}>{getStatIcon(stat.icon)}</div>
              <span className={styles.statValue}>{stat.value}</span>
              <span className={styles.statName}>{stat.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* DESCRIPTION */}
      <div className={styles.section}>
        <h3 className={styles.sectionTitle}>Description</h3>
        <p className={styles.descriptionText}>{item.description}</p>
        {item.lore && (
          <p className={styles.loreText}>
            <span className={styles.loreIcon}>📜</span>
            {item.lore}
          </p>
        )}
      </div>

      {/* SPECIAL ABILITIES */}
      {item.specialAbilities && item.specialAbilities.length > 0 && (
        <div className={styles.section}>
          <h3 className={styles.sectionTitle}>Special Abilities</h3>
          <div className={styles.abilitiesGrid}>
            {item.specialAbilities.map((ability, index) => (
              <div
                key={index}
                className={`${styles.abilityBox} ${activeAbilityIndex === index ? styles.active : ""}`}
                onMouseEnter={() => setActiveAbilityIndex(index)}
                onMouseLeave={() => setActiveAbilityIndex(null)}
              >
                <div className={styles.abilityIconContainer}>{getAbilityIcon(ability.icon)}</div>
                <span className={styles.abilityName}>{ability.name}</span>
                <span className={styles.abilityDescription}>{ability.description}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ACTION BUTTONS */}
      <div className={styles.footer}>
        <Button
          onClick={handleEquip}
          className={`${styles.actionButton} ${styles.equipButton}`}
        >
          <Unlock className={styles.buttonIcon} />
          EQUIP
        </Button>
        <Button
          onClick={handleInspect}
          className={`${styles.actionButton} ${styles.inspectButton}`}
        >
          <Eye className={styles.buttonIcon} />
          INSPECT
        </Button>
        <Button
          onClick={handleClose}
          className={`${styles.actionButton} ${styles.closeButton}`}
        >
          <X className={styles.buttonIcon} />
          CLOSE
        </Button>
      </div>

      {/* Equipment Slot Badge */}
      {item.equipmentSlot && (
        <div className={styles.slotBadge}>
          <Lock className={styles.slotIcon} />
          <span>{item.equipmentSlot.replace("-", " ")}</span>
        </div>
      )}
    </div>
  )
}
