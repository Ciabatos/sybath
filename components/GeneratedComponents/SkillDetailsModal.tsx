"use client"

import { Button } from "@/components/ui/button"
import { ArrowLeft, ArrowRight, Book, Crown, Eye, Flame, Gem, Heart, Lock, Shield, Star, Sword, X } from "lucide-react"
import { useState } from "react"
import { GiLightningArc } from "react-icons/gi"
import styles from "./styles/SkillDetailsModal.module.css"

export default function SkillDetailsModal() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [activeTab, setActiveTab] = useState<string>("bonuses")
  const [isLocked, setIsLocked] = useState<boolean>(false)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    skillId: "skl_042",
    skillName: "Shadow Step",
    description:
      "A forbidden technique of the Shadow Walkers, allowing the practitioner to phase through darkness and emerge from unseen angles. The skill requires absolute mastery over one's own shadow, bending it to become a conduit for movement.",
    level: 7,
    rank: "Master",
    rarity: "Rare",
    requirements: [
      { statName: "Strength", thresholdValue: 15 },
      { statName: "Dexterity", thresholdValue: 20 },
      { statName: "Intelligence", thresholdValue: 18 },
      { statName: "Willpower", thresholdValue: 16 },
    ],
    effects: [
      {
        effectId: "ef_001",
        name: "Phantom Movement",
        description: "Move silently through shadows, leaving no trace.",
        type: "Stealth",
        magnitude: "+50% Stealth",
      },
      {
        effectId: "ef_002",
        name: "Shadow Strike",
        description: "Deal bonus damage from unexpected angles.",
        type: "Combat",
        magnitude: "+15% Damage",
      },
      {
        effectId: "ef_003",
        name: "Dark Vision",
        description: "See clearly in low light conditions.",
        type: "Perception",
        magnitude: "Unlimited Range",
      },
    ],
    iconUrl: "/icons/shadow-step.svg",
    isLocked: false,
    unlockCost: { gold: 500, experience: 2500 },
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const rankProgress = [
    { title: "Novice", level: 1 },
    { title: "Adept", level: 4 },
    { title: "Master", level: 7 },
    { title: "Grandmaster", level: 9 },
    { title: "Legend", level: 10 },
  ]

  const currentRankIndex = rankProgress.findIndex((r) => r.title === MOCK.rank)
  const nextRankLevel = rankProgress[currentRankIndex + 1]?.level || 10
  const progressToNext = Math.min(MOCK.level, nextRankLevel - 1)
  const progressPercentage = ((MOCK.level - 1) / (nextRankLevel - 1)) * 100

  const rarityStars = [
    { tier: "Common", count: 1 },
    { tier: "Uncommon", count: 2 },
    { tier: "Rare", count: 3 },
    { tier: "Epic", count: 4 },
    { tier: "Legendary", count: 5 },
  ]

  const currentRarityIndex = rarityStars.findIndex((r) => r.tier === MOCK.rarity)
  const starCount = rarityStars[currentRarityIndex]?.count || 3

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleClose() {
    console.log("Closing skill details modal")
  }

  function handlePrevSkill() {
    console.log("Navigating to previous skill")
  }

  function handleNextSkill() {
    console.log("Navigating to next skill")
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.modal}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.decorativeBorderTop}></div>
        <div className={styles.headerContent}>
          <div className={styles.iconContainer}>
            {MOCK.isLocked ? (
              <Lock className={styles.lockIcon} />
            ) : (
              <Star
                className={styles.skillIcon}
                fill='currentColor'
              />
            )}
          </div>
          <div className={styles.titleSection}>
            <h2 className={styles.skillName}>{MOCK.skillName}</h2>
            <div className={styles.rarityContainer}>
              {[...Array(5)].map((_, i) => (
                <Star
                  key={i}
                  className={styles.starIcon}
                  fill={i < starCount ? "currentColor" : "none"}
                  stroke='currentColor'
                />
              ))}
            </div>
          </div>
        </div>
        <div className={styles.decorativeBorderBottom}></div>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Description - Scroll-like container */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Description</h3>
          <div className={styles.scrollContainer}>
            <p className={styles.descriptionText}>{MOCK.description}</p>
          </div>
        </section>

        {/* Level & Rank */}
        <section className={styles.section}>
          <div className={styles.rankHeader}>
            <Crown className={styles.crownIcon} />
            <span className={styles.rankTitle}>{MOCK.rank}</span>
          </div>
          <div className={styles.progressBarContainer}>
            <div
              className={styles.progressFill}
              style={{ width: `${progressPercentage}%` }}
            ></div>
          </div>
          <p className={styles.levelText}>
            Level {MOCK.level} of {nextRankLevel}
          </p>
        </section>

        {/* Requirements */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Requirements</h3>
          <div className={styles.requirementsGrid}>
            {MOCK.requirements.map(function (req) {
              return (
                <div
                  key={req.statName}
                  className={styles.reqCard}
                >
                  {req.statName === "Strength" && <Shield className={styles.reqIcon} />}
                  {req.statName === "Dexterity" && <Sword className={styles.reqIcon} />}
                  {req.statName === "Intelligence" && <Book className={styles.reqIcon} />}
                  {req.statName === "Willpower" && <Heart className={styles.reqIcon} />}
                  <span className={styles.reqLabel}>{req.statName}</span>
                  <span className={styles.reqValue}>≥{req.thresholdValue}</span>
                </div>
              )
            })}
          </div>
        </section>

        {/* Effects - Tabbed section */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Effects</h3>
          <div className={styles.tabsContainer}>
            <button
              className={styles.tabButton}
              onClick={() => setActiveTab("bonuses")}
            >
              <GiLightningArc className={styles.tabIcon} />
              Bonuses
            </button>
            <button
              className={styles.tabButton}
              onClick={() => setActiveTab("costs")}
            >
              <Gem className={styles.tabIcon} />
              Costs
            </button>
          </div>

          {activeTab === "bonuses" && (
            <div className={styles.effectsContainer}>
              {MOCK.effects.map(function (effect) {
                return (
                  <div
                    key={effect.effectId}
                    className={styles.effectPanel}
                  >
                    <div className={styles.effectHeader}>
                      {effect.type === "Stealth" && <Eye className={styles.effectIcon} />}
                      {effect.type === "Combat" && <Flame className={styles.effectIcon} />}
                      {effect.type === "Perception" && <GiLightningArc className={styles.effectIcon} />}
                      <span className={styles.effectName}>{effect.name}</span>
                    </div>
                    <p className={styles.effectDescription}>{effect.description}</p>
                    <span className={styles.effectMagnitude}>+{effect.magnitude}</span>
                  </div>
                )
              })}
            </div>
          )}

          {activeTab === "costs" && (
            <div className={styles.effectsContainer}>
              <div className={styles.costPanel}>
                <h4 className={styles.costTitle}>Unlock Cost</h4>
                <div className={styles.costGrid}>
                  <div className={styles.costItem}>
                    <span className={styles.costLabel}>Gold:</span>
                    <span className={styles.costValue}>{MOCK.unlockCost?.gold || "N/A"}</span>
                  </div>
                  <div className={styles.costItem}>
                    <span className={styles.costLabel}>Experience:</span>
                    <span className={styles.costValue}>{MOCK.unlockCost?.experience || "N/A"}</span>
                  </div>
                </div>
              </div>
            </div>
          )}
        </section>

        {/* Locked State */}
        {isLocked && (
          <section className={styles.section}>
            <div className={styles.lockedPanel}>
              <Lock className={styles.lockIconLarge} />
              <p>This skill is currently locked.</p>
            </div>
          </section>
        )}
      </div>

      {/* Navigation Footer */}
      <div className={styles.footer}>
        <Button
          onClick={handlePrevSkill}
          variant='outline'
          size='icon'
          className={styles.navButton}
        >
          <ArrowLeft className={styles.navIcon} />
        </Button>

        <span className={styles.skillNumber}>Skill {MOCK.skillId}</span>

        <Button
          onClick={handleNextSkill}
          variant='outline'
          size='icon'
          className={styles.navButton}
        >
          <ArrowRight className={styles.navIcon} />
        </Button>

        <Button
          onClick={handleClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <X className={styles.closeIcon} />
        </Button>
      </div>
    </div>
  )
}
