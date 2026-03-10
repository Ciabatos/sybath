"use client"
import { Button } from "@/components/ui/button"
import {
  Anvil,
  Apple,
  Backpack,
  Barrel,
  Beef,
  BookOpen,
  Castle,
  Crosshair,
  Crown,
  Flame,
  FlaskConical,
  Gem,
  Hammer,
  Heart,
  Landmark,
  ScrollText,
  Shield,
  Sword,
  Wheat,
} from "lucide-react"
import { useState } from "react"
import styles from "./styles/KnowledgeTree.module.css"
export default function KnowledgeTree() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [activeTab, setActiveTab] = useState<"combat" | "magic" | "crafting" | "leadership">("combat")
  const [isExpanded, setIsExpanded] = useState<boolean>(false)
  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    playerStats: {
      skillPoints: 12,
      level: 8,
      gold: 450,
      reputation: 78,
    },
    combatSkills: [
      {
        id: "1",
        name: "Longsword Mastery",
        icon: Sword,
        description: "+15% damage with longswords",
        cost: 3,
        learned: false,
      },
      {
        id: "2",
        name: "Shield Bash",
        icon: Shield,
        description: "+8% armor penetration on bash",
        cost: 2,
        learned: false,
      },
      {
        id: "3",
        name: "Parry Technique",
        icon: Crosshair,
        description: "+10% dodge chance against melee",
        cost: 4,
        learned: true,
      },
      {
        id: "4",
        name: "Heavy Armor Training",
        icon: Anvil,
        description: "+5% damage reduction in armor",
        cost: 3,
        learned: false,
      },
    ],
    magicSkills: [
      {
        id: "1",
        name: "Fireball Casting",
        icon: Flame,
        description: "Basic fire spell - 20 damage",
        cost: 4,
        learned: false,
      },
      { id: "2", name: "Healing Touch", icon: Heart, description: "Restore 30 HP to ally", cost: 3, learned: true },
      { id: "3", name: "Arcane Knowledge", icon: BookOpen, description: "+15% spell damage", cost: 5, learned: false },
    ],
    craftingSkills: [
      {
        id: "1",
        name: "Blacksmithing",
        icon: Hammer,
        description: "Create weapons +10% faster",
        cost: 3,
        learned: true,
      },
      { id: "2", name: "Alchemy", icon: FlaskConical, description: "Potions heal +25 HP", cost: 4, learned: false },
      { id: "3", name: "Leatherworking", icon: Apple, description: "+10% armor quality", cost: 2, learned: false },
    ],
    leadershipSkills: [
      {
        id: "1",
        name: "Command Presence",
        icon: Crown,
        description: "Troops fight +15% better",
        cost: 4,
        learned: true,
      },
      { id: "2", name: "Diplomacy", icon: Landmark, description: "+10% trade success rate", cost: 3, learned: false },
      {
        id: "3",
        name: "Fortification",
        icon: Castle,
        description: "Buildings +5% durability",
        cost: 5,
        learned: false,
      },
    ],
    resources: [
      { id: "1", name: "Wheat", quantity: 24, icon: Wheat },
      { id: "2", name: "Beef", quantity: 8, icon: Beef },
      { id: "3", name: "Flasks", quantity: 5, icon: FlaskConical },
      { id: "4", name: "Barrels", quantity: 12, icon: Barrel },
    ],
    ancientKnowledge: [
      { id: "1", name: "Runes of Power", icon: ScrollText, description: "Ancient magical inscriptions" },
      { id: "2", name: "Dragon Lore", icon: Gem, description: "Understanding dragon languages" },
      { id: "3", name: "Knightly Oaths", icon: Shield, description: "Medieval chivalric traditions" },
    ],
    medievalKnowledge: [
      { id: "1", name: "Siege Warfare", icon: Castle, description: "Castle defense and attack tactics" },
      { id: "2", name: "Feudal Law", icon: Crown, description: "Medieval legal systems" },
      { id: "3", name: "Heraldry", icon: Landmark, description: "Coat of arms design principles" },
    ],
    availableActions: ["Study Ancient Texts", "Train with Master", "Practice Spellcasting"],
  }
  // ── DERIVED ────────────────────────────────────────────────────────────────
  const totalCost = MOCK.combatSkills.reduce((sum, skill) => sum + skill.cost, 0)
  const canAffordCombat = MOCK.playerStats.skillPoints >= totalCost
  function handleLearnSkill(skillId: string) {
    console.log(`Learning skill ${skillId}`)
  }
  function handleClose() {
    console.log("Closing knowledge tree")
  }
  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>Knowledge Tree</h2>
          <p className={styles.subTitle}>Ancient & Medieval Wisdom</p>
          <span className={styles.coordinates}>
            {MOCK.playerStats.level}th Level · {MOCK.playerStats.skillPoints} Skill Points
          </span>
        </div>
        <Button
          onClick={handleClose}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <Backpack className={styles.closeIcon} />
        </Button>
      </div>
      {/* CONTENT */}
      <div className={styles.content}>
        {/* Stats Bar */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Resources</h3>
          <div className={styles.resourcesContainer}>
            {MOCK.resources.map(function (resource) {
              return (
                <div
                  key={resource.id}
                  className={styles.resourceItem}
                >
                  <resource.icon className={styles.resourceIcon} />
                  <span className={styles.resourceName}>{resource.name}</span>
                  <span className={styles.resourceValue}>{resource.quantity}</span>
                </div>
              )
            })}
          </div>
        </section>
        {/* Tabs */}
        <section className={styles.section}>
          <div className={styles.tabsContainer}>
            {["combat", "magic", "crafting", "leadership"].map(function (tab) {
              const TabName = tab.charAt(0).toUpperCase() + tab.slice(1)
              return (
                <button
                  key={tab}
                  onClick={() => setActiveTab(tab as typeof activeTab)}
                  className={`${styles.tab} ${activeTab === tab ? styles.active : ""}`}
                >
                  {TabName} Skills
                </button>
              )
            })}
          </div>
          {/* Combat Tab */}
          <div className={styles.skillContainer}>
            <h3 className={styles.sectionTitle}>Combat</h3>
            <div className={styles.skillsGrid}>
              {MOCK.combatSkills.map(function (skill) {
                return (
                  <div
                    key={skill.id}
                    className={styles.skillCard}
                  >
                    <div className={styles.skillHeader}>
                      <skill.icon className={styles.skillIcon} />
                      <span className={styles.skillName}>{skill.name}</span>
                    </div>
                    <p className={styles.skillDescription}>{skill.description}</p>
                    <div className={styles.skillFooter}>
                      <span className={styles.costLabel}>Cost:</span>
                      <span className={styles.costValue}>{skill.cost} SP</span>
                      {skill.learned ? (
                        <span className={styles.learntBadge}>Learned</span>
                      ) : canAffordCombat ? (
                        <Button
                          onClick={() => handleLearnSkill(skill.id)}
                          size='sm'
                          variant='default'
                        >
                          Learn
                        </Button>
                      ) : (
                        <span className={styles.disabledAction}>Not enough points</span>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
          {/* Magic Tab */}
          <div className={styles.skillContainer}>
            <h3 className={styles.sectionTitle}>Magic</h3>
            <div className={styles.skillsGrid}>
              {MOCK.magicSkills.map(function (skill) {
                return (
                  <div
                    key={skill.id}
                    className={styles.skillCard}
                  >
                    <div className={styles.skillHeader}>
                      <skill.icon className={styles.skillIcon} />
                      <span className={styles.skillName}>{skill.name}</span>
                    </div>
                    <p className={styles.skillDescription}>{skill.description}</p>
                    <div className={styles.skillFooter}>
                      <span className={styles.costLabel}>Cost:</span>
                      <span className={styles.costValue}>{skill.cost} SP</span>
                      {skill.learned ? (
                        <span className={styles.learntBadge}>Learned</span>
                      ) : canAffordCombat ? (
                        <Button
                          onClick={() => handleLearnSkill(skill.id)}
                          size='sm'
                          variant='default'
                        >
                          Learn
                        </Button>
                      ) : (
                        <span className={styles.disabledAction}>Not enough points</span>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
          {/* Crafting Tab */}
          <div className={styles.skillContainer}>
            <h3 className={styles.sectionTitle}>Crafting</h3>
            <div className={styles.skillsGrid}>
              {MOCK.craftingSkills.map(function (skill) {
                return (
                  <div
                    key={skill.id}
                    className={styles.skillCard}
                  >
                    <div className={styles.skillHeader}>
                      <skill.icon className={styles.skillIcon} />
                      <span className={styles.skillName}>{skill.name}</span>
                    </div>
                    <p className={styles.skillDescription}>{skill.description}</p>
                    <div className={styles.skillFooter}>
                      <span className={styles.costLabel}>Cost:</span>
                      <span className={styles.costValue}>{skill.cost} SP</span>
                      {skill.learned ? (
                        <span className={styles.learntBadge}>Learned</span>
                      ) : canAffordCombat ? (
                        <Button
                          onClick={() => handleLearnSkill(skill.id)}
                          size='sm'
                          variant='default'
                        >
                          Learn
                        </Button>
                      ) : (
                        <span className={styles.disabledAction}>Not enough points</span>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
          {/* Leadership Tab */}
          <div className={styles.skillContainer}>
            <h3 className={styles.sectionTitle}>Leadership</h3>
            <div className={styles.skillsGrid}>
              {MOCK.leadershipSkills.map(function (skill) {
                return (
                  <div
                    key={skill.id}
                    className={styles.skillCard}
                  >
                    <div className={styles.skillHeader}>
                      <skill.icon className={styles.skillIcon} />
                      <span className={styles.skillName}>{skill.name}</span>
                    </div>
                    <p className={styles.skillDescription}>{skill.description}</p>
                    <div className={styles.skillFooter}>
                      <span className={styles.costLabel}>Cost:</span>
                      <span className={styles.costValue}>{skill.cost} SP</span>
                      {skill.learned ? (
                        <span className={styles.learntBadge}>Learned</span>
                      ) : canAffordCombat ? (
                        <Button
                          onClick={() => handleLearnSkill(skill.id)}
                          size='sm'
                          variant='default'
                        >
                          Learn
                        </Button>
                      ) : (
                        <span className={styles.disabledAction}>Not enough points</span>
                      )}
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
          {/* Ancient Knowledge */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Ancient Wisdom</h3>
            <div className={styles.knowledgeContainer}>
              {MOCK.ancientKnowledge.map(function (knowledge) {
                return (
                  <div
                    key={knowledge.id}
                    className={styles.knowledgeItem}
                  >
                    <knowledge.icon className={styles.knowledgeIcon} />
                    <span className={styles.knowledgeName}>{knowledge.name}</span>
                    <span className={styles.knowledgeDescription}>{knowledge.description}</span>
                  </div>
                )
              })}
            </div>
          </section>
          {/* Medieval Knowledge */}
          <section className={styles.section}>
            <h3 className={styles.sectionTitle}>Medieval Lore</h3>
            <div className={styles.knowledgeContainer}>
              {MOCK.medievalKnowledge.map(function (knowledge) {
                return (
                  <div
                    key={knowledge.id}
                    className={styles.knowledgeItem}
                  >
                    <knowledge.icon className={styles.knowledgeIcon} />
                    <span className={styles.knowledgeName}>{knowledge.name}</span>
                    <span className={styles.knowledgeDescription}>{knowledge.description}</span>
                  </div>
                )
              })}
            </div>
          </section>
          {/* Action Buttons */}
          <div className={styles.actionButtons}>
            {MOCK.availableActions.map(function (action, index) {
              return (
                <Button
                  key={index}
                  size='sm'
                  variant='outline'
                >
                  {action}
                </Button>
              )
            })}
          </div>
          {/* Total Cost Display */}
          <div className={styles.totalCost}>
            <span className={styles.costLabel}>Total Available Skills:</span>
            <span className={styles.costValue}>{totalCost} SP</span>
            <span className={styles.pointsRemaining}>({MOCK.playerStats.skillPoints - totalCost} remaining)</span>
          </div>
        </section>
      </div>
    </div>
  )
}
