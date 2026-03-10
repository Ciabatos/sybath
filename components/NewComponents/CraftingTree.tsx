"use client"

import { Button } from "@/components/ui/button"
import {
  Binoculars,
  BookOpen,
  Castle,
  Clock,
  Coins,
  Compass,
  Crosshair,
  Gem,
  Heart,
  Hourglass,
  MapPin,
  Shield,
  Skull,
  Sparkles,
  Sword,
  Telescope,
  WandSparkles,
  Zap,
} from "lucide-react"
import { useState } from "react"
import styles from "./styles/CraftingTree.module.css"

export default function CraftingTree() {
  const [activeTab, setActiveTab] = useState<"weapons" | "armor" | "spells">("weapons")
  const [selectedRecipe, setSelectedRecipe] = useState<number | null>(null)
  const [skillPoints, setSkillPoints] = useState(3)

  const MOCK = {
    player: {
      skillPoints: 3,
      gold: 1250,
      reputation: 45,
      level: 12,
    },
    recipes: [
      {
        id: 1,
        name: "Iron Longsword",
        category: "weapons",
        tier: 1,
        cost: { gold: 50, materials: [{ icon: "Anvil", count: 3 }] },
        stats: [
          { icon: "Heart", value: 25 },
          { icon: "Crosshair", value: 15 },
        ],
        description: "A sturdy blade forged in the fires of ancient forges.",
      },
      {
        id: 2,
        name: "Dragon Scale Armor",
        category: "armor",
        tier: 3,
        cost: { gold: 500, materials: [{ icon: "Gem", count: 10 }] },
        stats: [
          { icon: "Heart", value: 80 },
          { icon: "Shield", value: 60 },
          { icon: "Flame", value: 20 },
        ],
        description: "Armor woven from dragon scales, granting fire resistance.",
      },
      {
        id: 3,
        name: "Arcane Staff of Power",
        category: "spells",
        tier: 4,
        cost: { gold: 1000, materials: [{ icon: "WandSparkles", count: 5 }] },
        stats: [
          { icon: "Zap", value: 120 },
          { icon: "Skull", value: 40 },
          { icon: "Sparkles", value: 80 },
        ],
        description: "Channel ancient magic with this mystical staff.",
      },
      {
        id: 4,
        name: "Knightly Shield",
        category: "armor",
        tier: 2,
        cost: { gold: 150, materials: [{ icon: "Shield", count: 2 }] },
        stats: [
          { icon: "Heart", value: 35 },
          { icon: "Shield", value: 45 },
        ],
        description: "A shield bearing the crest of noble houses.",
      },
      {
        id: 5,
        name: "Shadow Dagger",
        category: "weapons",
        tier: 2,
        cost: { gold: 100, materials: [{ icon: "Skull", count: 3 }] },
        stats: [
          { icon: "Crosshair", value: 30 },
          { icon: "Heart", value: 15 },
          { icon: "Ghost", count: 2 },
        ],
        description: "Blades that strike from the shadows.",
      },
      {
        id: 6,
        name: "Healing Potion",
        category: "spells",
        tier: 1,
        cost: { gold: 30, materials: [{ icon: "FlaskConical", count: 2 }] },
        stats: [{ icon: "Heart", value: 50 }],
        description: "Restores health when consumed.",
      },
    ],
    categories: [
      { id: "weapons", label: "Weapons", icon: Sword },
      { id: "armor", label: "Armor", icon: Shield },
      { id: "spells", label: "Spells", icon: WandSparkles },
    ],
  }

  function handleCraft(recipeId: number) {}

  function handleBuy(recipeId: number) {}

  function handleInspect(recipeId: number) {}

  return (
    <div className={styles.panel}>
      <div className={styles.titleBar}>
        <div className={styles.title}>
          <Castle size={24} />
          <span>Crafting Tree</span>
        </div>
        <div className={styles.skillPoints}>
          <Heart size={16} />
          {MOCK.player.skillPoints}
        </div>
      </div>

      <div className={styles.content}>
        <div className={styles.tabs}>
          {MOCK.categories.map((category) => (
            <button
              key={category.id}
              className={`${styles.tab} ${activeTab === category.id ? styles.active : ""}`}
              onClick={() => setActiveTab(category.id as typeof activeTab)}
            >
              <category.icon size={18} />
              {category.label}
            </button>
          ))}
        </div>

        <div className={styles.recipeList}>
          {MOCK.recipes
            .filter((recipe) => recipe.category === activeTab)
            .map((recipe) => (
              <div
                key={recipe.id}
                className={`${styles.recipeCard} ${selectedRecipe === recipe.id ? styles.selected : ""}`}
                onClick={() => setSelectedRecipe(recipe.id)}
              >
                <div className={styles.recipeHeader}>
                  <div className={styles.recipeIcon}>
                    {activeTab === "weapons" && <Sword size={32} />}
                    {activeTab === "armor" && <Shield size={32} />}
                    {activeTab === "spells" && <WandSparkles size={32} />}
                  </div>
                  <div className={styles.recipeInfo}>
                    <div className={styles.recipeName}>{recipe.name}</div>
                    <div className={styles.tierBadge}>Tier {recipe.tier}</div>
                  </div>
                </div>

                <div className={styles.recipeDetails}>
                  <div className={styles.costRow}>
                    <span className={styles.costIcon}>
                      <Coins size={14} />
                    </span>
                    {MOCK.player.gold}
                  </div>
                  {/* {recipe.materials.map((material, index) => (
                    <span
                      key={index}
                      className={styles.materialCost}
                    >
                      <Anvil size={12} />
                      {material.count}
                    </span>
                  ))} */}
                </div>

                <div className={styles.statsRow}>
                  {recipe.stats.map((stat, index) => (
                    <span
                      key={index}
                      className={styles.statItem}
                    >
                      {activeTab === "weapons" && stat.icon === "Heart" ? (
                        <Heart size={14} />
                      ) : activeTab === "weapons" && stat.icon === "Crosshair" ? (
                        <Crosshair size={14} />
                      ) : activeTab === "armor" && stat.icon === "Heart" ? (
                        <Heart size={14} />
                      ) : activeTab === "armor" && stat.icon === "Shield" ? (
                        <Shield size={14} />
                      ) : activeTab === "spells" && stat.icon === "Zap" ? (
                        <Zap size={14} />
                      ) : activeTab === "spells" && stat.icon === "Skull" ? (
                        <Skull size={14} />
                      ) : activeTab === "spells" && stat.icon === "Sparkles" ? (
                        <Sparkles size={14} />
                      ) : null}
                      {stat.value}
                    </span>
                  ))}
                </div>

                <div className={styles.description}>{recipe.description}</div>

                <div className={styles.actions}>
                  <Button onClick={() => handleCraft(recipe.id)}>Craft</Button>
                  <Button disabled>Buy</Button>
                  <Button
                    variant='ghost'
                    onClick={() => handleInspect(recipe.id)}
                  >
                    Inspect
                  </Button>
                </div>
              </div>
            ))}
        </div>

        {selectedRecipe !== null && (
          <div className={styles.recipeDetailsPanel}>
            <div className={styles.panelHeader}>
              <Clock size={16} />
              <span>Crafting Time</span>
            </div>
            <div className={styles.timeRow}>
              <Hourglass size={14} />
              2h 30m
            </div>

            <div className={styles.panelHeader}>
              <Compass size={16} />
              <span>Requirements</span>
            </div>
            <div className={styles.requirementsRow}>
              <Binoculars size={14} />
              Level 5
            </div>

            <div className={styles.panelHeader}>
              <MapPin size={16} />
              <span>Location</span>
            </div>
            <div className={styles.locationRow}>
              <Castle size={14} />
              Blacksmith's Forge
            </div>

            <div className={styles.panelHeader}>
              <Telescope size={16} />
              <span>Rarity</span>
            </div>
            <div className={styles.rarityRow}>
              <Gem size={14} />
              Common
            </div>
          </div>
        )}

        {selectedRecipe === null && (
          <div className={styles.emptyState}>
            <BookOpen size={32} />
            <span>Select a recipe to view details</span>
          </div>
        )}
      </div>
    </div>
  )
}
