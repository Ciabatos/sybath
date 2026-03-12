"use client"

import {
  BookOpen,
  CheckCircle,
  Clock,
  Crown,
  Flame,
  Gem,
  Heart,
  Lock,
  Ribbon,
  Scroll,
  Shield,
  Star,
  Trophy,
} from "lucide-react"
import { useState } from "react"
import styles from "./styles/PlayerQuestDiary.module.css"

export default function PlayerQuestDiary() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [activeTab, setActiveTab] = useState<"active" | "completed" | "available">("active")
  const [selectedQuestId, setSelectedQuestId] = useState<string | null>(null)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    playerCharacterName: "Lord Valerius the Brave",
    playerTitle: "Duke of Ironwood",
    royalCrestEmblem: "👑",

    quests: [
      {
        questId: "q001",
        questTitle: "The Shadow of Blackwood Keep",
        questDescription:
          "Dark forces have gathered in the ancient keep. The local villagers report strange disappearances and hear whispers of a cursed artifact buried deep within the castle's dungeons.",
        questStatus: "active",
        currentStage: 2,
        totalStages: 4,
        progressPercentage: 50,
        goldReward: 1500,
        xpReward: 3200,
        itemRewards: [
          { itemId: "sword_ancient", itemName: "Blade of Shadows", quantity: 1 },
          { itemId: "potion_health", itemName: "Health Potion", quantity: 5 },
        ],
        requirements: {
          levelRequired: 25,
          itemsNeeded: ["Key to Blackwood Gate", "Diplomatic Letter"],
          factionStatus: "Neutral",
        },
        completionDate: null,
        questType: "main",
        difficultyRating: 4,
        isRepeatable: false,
      },
      {
        questId: "q002",
        questTitle: "Harvest of the Golden Fields",
        questDescription:
          "The harvest festival approaches, but a blight threatens the crops. Help the farmers protect their fields from the creeping darkness that has taken root in the soil.",
        questStatus: "completed",
        currentStage: 3,
        totalStages: 3,
        progressPercentage: 100,
        goldReward: 850,
        xpReward: 1500,
        itemRewards: [
          { itemId: "grain_bountiful", itemName: "Bountiful Grain", quantity: 20 },
          { itemId: "seed_magic", itemName: "Magic Seeds", quantity: 3 },
        ],
        requirements: {
          levelRequired: 15,
          itemsNeeded: ["Farmer's Blessing"],
          factionStatus: "Ally",
        },
        completionDate: new Date("2026-03-10"),
        questType: "side",
        difficultyRating: 2,
        isRepeatable: true,
      },
      {
        questId: "q003",
        questTitle: "Whispers of the Deep Dungeon",
        questDescription:
          "Ancient ruins beneath the mountains hold secrets of a forgotten civilization. The whispers call to those brave enough to listen, but few have returned.",
        questStatus: "locked",
        currentStage: 1,
        totalStages: 6,
        progressPercentage: 0,
        goldReward: 2500,
        xpReward: 5000,
        itemRewards: [
          { itemId: "artifact_ancient", itemName: "Ancient Artifact", quantity: 1 },
          { itemId: "gem_ruby", itemName: "Ruby Gemstone", quantity: 2 },
        ],
        requirements: {
          levelRequired: 40,
          itemsNeeded: ["Dungeon Key", "Explorer's Map"],
          factionStatus: "Unknown",
        },
        completionDate: null,
        questType: "dungeon",
        difficultyRating: 5,
        isRepeatable: false,
      },
      {
        questId: "q004",
        questTitle: "Treasure of the Lost Kingdom",
        questDescription:
          "Rumors speak of a lost kingdom buried beneath the desert sands. Its treasures are said to be beyond measure, guarded by ancient traps and forgotten guardians.",
        questStatus: "available",
        currentStage: 1,
        totalStages: 5,
        progressPercentage: 0,
        goldReward: 3000,
        xpReward: 4500,
        itemRewards: [
          { itemId: "jewel_emerald", itemName: "Emerald Jewel", quantity: 1 },
          { itemId: "gold_ingot", itemName: "Gold Ingot", quantity: 10 },
        ],
        requirements: {
          levelRequired: 35,
          itemsNeeded: ["Desert Compass"],
          factionStatus: "Neutral",
        },
        completionDate: null,
        questType: "treasure",
        difficultyRating: 4,
        isRepeatable: false,
      },
      {
        questId: "q005",
        questTitle: "Hero's Call to Arms",
        questDescription:
          "The realm faces a great threat. Heroes from across the land are needed to defend our borders against the encroaching darkness.",
        questStatus: "active",
        currentStage: 1,
        totalStages: 8,
        progressPercentage: 12.5,
        goldReward: 5000,
        xpReward: 8000,
        itemRewards: [
          { itemId: "weapon_legendary", itemName: "Legendary Weapon", quantity: 1 },
          { itemId: "armor_epic", itemName: "Epic Armor Set", quantity: 1 },
        ],
        requirements: {
          levelRequired: 50,
          itemsNeeded: ["Hero's Token"],
          factionStatus: "Ally",
        },
        completionDate: null,
        questType: "heroic",
        difficultyRating: 5,
        isRepeatable: false,
      },
    ],
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const filteredQuests = MOCK.quests.filter(function (quest) {
    if (activeTab === "active") return quest.questStatus === "active"
    if (activeTab === "completed") return quest.questStatus === "completed"
    return quest.questStatus === "available" || quest.questStatus === "locked"
  })

  const getStatusIcon = function (status: string) {
    switch (status) {
      case "active":
        return <Flame className={styles.statusIconActive} />
      case "completed":
        return <CheckCircle className={styles.statusIconCompleted} />
      case "locked":
        return <Lock className={styles.statusIconLocked} />
      default:
        return <Shield className={styles.statusIconDefault} />
    }
  }

  const getStatusColor = function (status: string) {
    switch (status) {
      case "active":
        return styles.colorActive
      case "completed":
        return styles.colorCompleted
      case "locked":
        return styles.colorLocked
      default:
        return styles.colorAvailable
    }
  }

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleTabChange(tab: "active" | "completed" | "available") {
    setActiveTab(tab)
  }

  function handleQuestClick(questId: string) {
    setSelectedQuestId(questId)
  }

  function handleCloseModal() {
    setSelectedQuestId(null)
  }

  function handleClaimRewards() {
    console.log("Claiming rewards for quest")
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>{MOCK.playerCharacterName}</h2>
          <p className={styles.subTitle}>{MOCK.playerTitle}</p>
          <span className={styles.royalCrest}>{MOCK.royalCrestEmblem}</span>
        </div>
      </div>

      {/* TAB NAVIGATION */}
      <div className={styles.tabNavigation}>
        <button
          className={`${styles.tab} ${activeTab === "active" ? styles.tabActive : ""}`}
          onClick={() => handleTabChange("active")}
        >
          <Scroll className={styles.tabIcon} />
          <span>Active Quests</span>
          {activeTab === "active" && (
            <div className={styles.waxSealIndicator}>
              <Ribbon />
            </div>
          )}
        </button>
        <button
          className={`${styles.tab} ${activeTab === "completed" ? styles.tabActive : ""}`}
          onClick={() => handleTabChange("completed")}
        >
          <CheckCircle className={styles.tabIcon} />
          <span>Completed Quests</span>
          {activeTab === "completed" && (
            <div className={styles.waxSealIndicator}>
              <Ribbon />
            </div>
          )}
        </button>
        <button
          className={`${styles.tab} ${activeTab === "available" ? styles.tabActive : ""}`}
          onClick={() => handleTabChange("available")}
        >
          <Crown className={styles.tabIcon} />
          <span>Available Quests</span>
          {activeTab === "available" && (
            <div className={styles.waxSealIndicator}>
              <Ribbon />
            </div>
          )}
        </button>
      </div>

      {/* QUEST LIST CONTAINER */}
      <div className={styles.questListContainer}>
        {filteredQuests.map(function (quest) {
          return (
            <div
              key={quest.questId}
              className={`${styles.questEntryCard} ${getStatusColor(quest.questStatus)}`}
              onClick={() => handleQuestClick(quest.questId)}
              onMouseEnter={(e) => (e.currentTarget.style.transform = "scale(1.02)")}
              onMouseLeave={(e) => (e.currentTarget.style.transform = "scale(1)")}
            >
              {/* Quest Header */}
              <div className={styles.questHeader}>
                <div className={styles.questTitleSection}>
                  <h3 className={styles.questTitle}>{quest.questTitle}</h3>
                  <span className={`${styles.questStatusBadge} ${getStatusColor(quest.questStatus)}`}>
                    {getStatusIcon(quest.questStatus)}
                    <span>{quest.questType.toUpperCase()}</span>
                  </span>
                </div>
                <div className={styles.stageIndicator}>
                  <Gem className={styles.stageIcon} />
                  <span>
                    {quest.currentStage}/{quest.totalStages}
                  </span>
                </div>
              </div>

              {/* Quest Description */}
              <p className={styles.questDescription}>{quest.questDescription}</p>

              {/* Progress Bar (Medieval Health/Stamina Style) */}
              <div className={styles.progressBarContainer}>
                <div className={styles.progressLabel}>
                  <Heart className={styles.progressIcon} />
                  <span>Progress</span>
                </div>
                <div className={styles.progressBarFill}>
                  <div
                    className={`${styles.progressBarFillInner} ${getStatusColor(quest.questStatus)}`}
                    style={{ width: `${quest.progressPercentage}%` }}
                  />
                </div>
              </div>

              {/* Quest Requirements */}
              <div className={styles.requirementsSection}>
                <span className={styles.requirementsLabel}>Requirements:</span>
                <div className={styles.requirementsList}>
                  {quest.requirements.levelRequired && (
                    <div
                      className={`${styles.requirementItem} ${quest.requirements.levelRequired <= 50 ? styles.metRequirement : ""}`}
                    >
                      <CheckCircle className={styles.requirementIcon} />
                      <span>Level {quest.requirements.levelRequired}</span>
                    </div>
                  )}
                  {quest.requirements.itemsNeeded &&
                    quest.requirements.itemsNeeded.map(function (item, index) {
                      return (
                        <div
                          key={index}
                          className={`${styles.requirementItem} ${!item.includes("Key") ? styles.metRequirement : ""}`}
                        >
                          <CheckCircle className={styles.requirementIcon} />
                          <span>{item}</span>
                        </div>
                      )
                    })}
                  {quest.requirements.factionStatus && (
                    <div
                      className={`${styles.requirementItem} ${quest.requirements.factionStatus === "Ally" ? styles.metRequirement : ""}`}
                    >
                      <CheckCircle className={styles.requirementIcon} />
                      <span>Faction: {quest.requirements.factionStatus}</span>
                    </div>
                  )}
                </div>
              </div>

              {/* Rewards Display */}
              <div className={styles.rewardSection}>
                <span className={styles.rewardsLabel}>Rewards:</span>
                <div className={styles.rewardsList}>
                  {quest.goldReward && (
                    <div className={styles.rewardItem}>
                      <Star className={styles.rewardIcon} />
                      <span>{quest.goldReward} gold</span>
                    </div>
                  )}
                  {quest.xpReward && (
                    <div className={styles.rewardItem}>
                      <Star className={styles.rewardIcon} />
                      <span>{quest.xpReward} XP</span>
                    </div>
                  )}
                  {quest.itemRewards &&
                    quest.itemRewards.map(function (reward, index) {
                      return (
                        <div
                          key={index}
                          className={styles.rewardItem}
                        >
                          <Gem className={styles.rewardIcon} />
                          <span>
                            {reward.quantity}x {reward.itemName}
                          </span>
                        </div>
                      )
                    })}
                </div>
              </div>

              {/* Difficulty Rating */}
              <div className={styles.difficultySection}>
                <Trophy className={styles.difficultyIcon} />
                <span>Difficulty: {quest.difficultyRating}/5</span>
              </div>

              {/* Repeatable Indicator */}
              {quest.isRepeatable && (
                <div className={styles.repeatableIndicator}>
                  <Ribbon className={styles.repeatableIcon} />
                  <span>Repeatable Quest</span>
                </div>
              )}

              {/* Completion Date */}
              {quest.completionDate && (
                <div className={styles.completionSection}>
                  <Clock className={styles.completionIcon} />
                  <span>Completed: {quest.completionDate.toLocaleDateString()}</span>
                </div>
              )}

              {/* Ornate Divider */}
              <div className={styles.questDivider} />
            </div>
          )
        })}
      </div>

      {/* QUEST COMPLETION MODAL */}
      {selectedQuestId && (
        <div className={styles.modalOverlay}>
          <div className={styles.completionModal}>
            {/* Animated Background Effects */}
            <div className={styles.confettiEffect}>
              {[...Array(20)].map((_, i) => (
                <div
                  key={i}
                  className={styles.confettiParticle}
                >
                  {["🌟", "✨", "💫", "🔥"][Math.floor(Math.random() * 4)]}
                </div>
              ))}
            </div>

            {/* Modal Content */}
            <div className={styles.modalContent}>
              <div className={styles.modalHeader}>
                <Star className={styles.sealIcon} />
                <h2 className={styles.modalTitle}>Quest Completed!</h2>
              </div>

              <div className={styles.modalBody}>
                <p className={styles.completionMessage}>
                  Congratulations, {MOCK.playerCharacterName}! You have completed your quest.
                </p>

                {/* Rewards Summary */}
                <div className={styles.rewardsSummary}>
                  <h3 className={styles.rewardsSummaryTitle}>Your Rewards:</h3>
                  <div className={styles.rewardCountdown}>
                    {MOCK.quests.find((q) => q.questId === selectedQuestId)?.goldReward && (
                      <div className={styles.rewardItem}>
                        <Star className={styles.rewardIcon} />
                        <span>{MOCK.quests.find((q) => q.questId === selectedQuestId)?.goldReward} gold</span>
                      </div>
                    )}
                    {MOCK.quests.find((q) => q.questId === selectedQuestId)?.xpReward && (
                      <div className={styles.rewardItem}>
                        <Star className={styles.rewardIcon} />
                        <span>{MOCK.quests.find((q) => q.questId === selectedQuestId)?.xpReward} XP</span>
                      </div>
                    )}
                  </div>

                  {/* Item Rewards */}
                  {MOCK.quests.find((q) => q.questId === selectedQuestId)?.itemRewards && (
                    <div className={styles.itemRewards}>
                      <h4 className={styles.itemRewardsTitle}>Items:</h4>
                      {MOCK.quests
                        .find((q) => q.questId === selectedQuestId)
                        ?.itemRewards.map(function (reward, index) {
                          return (
                            <div
                              key={index}
                              className={styles.rewardItem}
                            >
                              <Gem className={styles.rewardIcon} />
                              <span>
                                {reward.quantity}x {reward.itemName}
                              </span>
                            </div>
                          )
                        })}
                    </div>
                  )}
                </div>

                {/* Quest Log Entry */}
                <div className={styles.questLogEntry}>
                  <BookOpen className={styles.logIcon} />
                  <p>Quest entry added to your royal chronicles.</p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className={styles.modalActions}>
                <button
                  className={`${styles.claimButton} ${getStatusColor("active")}`}
                  onClick={handleClaimRewards}
                >
                  <Star className={styles.sealIcon} />
                  <span>Claim Rewards</span>
                </button>
                <button
                  className={`${styles.closeButton} ${getStatusColor("completed")}`}
                  onClick={handleCloseModal}
                >
                  <CheckCircle className={styles.closeIcon} />
                  <span>Continue</span>
                </button>
              </div>

              {/* Wax Stamp Animation */}
              <div className={styles.waxStampAnimation}>
                <Star className={styles.waxStamp} />
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
