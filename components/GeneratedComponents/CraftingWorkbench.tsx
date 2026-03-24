"use client"

import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Progress } from "@/components/ui/progress"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Hammer, Scroll, Shield, Sword, Flask, Gem, Coin, Clock, Check, X, AlertTriangle, Sparkles } from "lucide-react"
import {
  GiPickaxe,
  GiChest,
  GiPotion,
  GiRing,
  GiAxe,
  GiArmor,
  GiFire,
  GiWater,
  GiEarth,
  GiAir,
  GiStar,
  GiMoon,
} from "react-icons/gi"
import { useState } from "react"
import styles from "./CraftingWorkbench.module.css"

export default function CraftingWorkbench() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [selectedRecipeId, setSelectedRecipeId] = useState<string>("sword_of_valour")
  const [isCraftingInProgress, setIsCraftingInProgress] = useState<boolean>(false)
  const [progressPercentage, setProgressPercentage] = useState<number>(0)
  const [successMessage, setSuccessMessage] = useState<string | null>(null)
  const [failureReason, setFailureReason] = useState<string | null>(null)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    recipes: [
      {
        id: "sword_of_valour",
        name: "Sword of Valour",
        description: "A legendary blade forged in the fires of ancient forges. Its edge gleams with an otherworldly light, said to be blessed by the gods themselves.",
        category: "weapons",
        craftingCost: 500,
        craftingDuration: 120,
        requiredMaterials: [
          { materialId: "steel_ingot", materialName: "Steel Ingot", quantityRequired: 3 },
          { materialId: "gem_ruby", materialName: "Ruby Gemstone", quantityRequired: 2 },
          { materialId: "leather_strap", materialName: "Leather Strap", quantityRequired: 1 },
        ],
        itemStats: { damage: 45, durability: 800, specialEffect: "+10% Critical Hit" },
      },
      {
        id: "armor_plate",
        name: "Plate Armor of the Guardian",
        description: "Heavy armor worn by the legendary guardians of the kingdom. Each plate bears intricate engravings depicting scenes from ancient battles.",
        category: "armor",
        craftingCost: 750,
        craftingDuration: 180,
        requiredMaterials: [
          { materialId: "iron_ingot", materialName: "Iron Ingot", quantityRequired: 5 },
          { materialId: "gem_emerald", materialName: "Emerald Gemstone", quantityRequired: 3 },
          { materialId: "leather_strap", materialName: "Leather Strap", quantityRequired: 2 },
        ],
        itemStats: { defense: 65, durability: 1000, specialEffect: "+15% Damage Reduction" },
      },
      {
        id: "potion_health",
        name: "Potion of Vitality",
        description: "A glowing green elixir that restores health and fortifies the body against ailments. The scent of herbs fills the air when uncorked.",
        category: "potions",
        craftingCost: 100,
        craftingDuration: 30,
        requiredMaterials: [
          { materialId: "herb_mandrake", materialName: "Mandrake Root", quantityRequired: 2 },
          { materialId: "water_spring", materialName: "Spring Water", quantityRequired: 1 },
          { materialId: "gem_crystal", materialName: "Crystal Shard", quantityRequired: 1 },
        ],
        itemStats: { healing: 50, duration: 300, specialEffect: "Restores stamina" },
      },
    ],

    availableMaterials: [
      { materialId: "steel_ingot", materialName: "Steel Ingot", quantityAvailable: 4 },
      { materialId: "gem_ruby", materialName: "Ruby Gemstone", quantityAvailable: 1 },
      { materialId: "leather_strap", materialName: "Leather Strap", quantityAvailable: 3 },
      { materialId: "iron_ingot", materialName: "Iron Ingot", quantityAvailable: 8 },
      { materialId: "gem_emerald", materialName: "Emerald Gemstone", quantityAvailable: 2 },
      { materialId: "herb_mandrake", materialName: "Mandrake Root", quantityAvailable: 5 },
      { materialId: "water_spring", materialName: "Spring Water", quantityAvailable: 10 },
      { materialId: "gem_crystal", materialName: "Crystal Shard", quantityAvailable: 3 },
    ],

    craftingCost: 500,
    craftingDuration: 120,
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const selectedRecipe = MOCK.recipes.find((r) => r.id === selectedRecipeId) || MOCK.recipes[0]
  const missingMaterials = selectedRecipe.requiredMaterials.map(function (required) {
    const available = MOCK.availableMaterials.find(
      (m) => m.materialId === required.materialId
    )
    return available
      ? { materialId: required.materialId, materialName: required.materialName, deficitAmount: Math.max(0, required.quantityRequired - available.quantityAvailable) }
      : { materialId: required.materialId, materialName: required.materialName, deficitAmount: required.quantityRequired }
  }).filter((m) => m.deficitAmount > 0)

  const hasAllMaterials = missingMaterials.length === 0
  const canAffordCost = true // Simplified for demo

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleStartCrafting() {
    if (!hasAllMaterials || !canAffordCost) return
    
    setIsCraftingInProgress(true)
    setProgressPercentage(0)
    setSuccessMessage(null)
    setFailureReason(null)

    // Simulate crafting progress
    const interval = setInterval(function () {
      setProgressPercentage((prev) => {
        if (prev >= 100) {
          clearInterval(interval)
          setIsCraftingInProgress(false)
          setSuccessMessage("Successfully crafted item!")
          return 100
        }
        return prev + 5
      })
    }, 200)
  }

  function handleCancelCrafting() {
    setIsCraftingInProgress(false)
    setProgressPercentage(0)
    setSuccessMessage(null)
    setFailureReason("Crafting cancelled by player.")
  }

  function handleSelectRecipe(recipeId: string) {
    setSelectedRecipeId(recipeId)
    setSuccessMessage(null)
    setFailureReason(null)
    setProgressPercentage(0)
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>Crafting Workbench</h2>
          <p className={styles.subTitle}>Forge legendary items with ancient techniques</p>
          <span className={styles.coordinates}>{selectedRecipe.category.toUpperCase()}</span>
        </div>
        <Button
          onClick={() => {}}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <X className={styles.closeIcon} />
        </Button>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Recipe Selection */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Select Recipe</h3>
          <Tabs value={selectedRecipeId} onValueChange={(value) => handleSelectRecipe(value)}>
            <TabsList className={styles.tabsList}>
              {MOCK.recipes.map(function (recipe) {
                return (
                  <TabsTrigger key={recipe.id} value={recipe.id} className={styles.tabTrigger}>
                    <span className={styles.recipeIcon}>{getCategoryIcon(recipe.category)}</span>
                    <span>{recipe.name}</span>
                  </TabsTrigger>
                )
              })}
            </TabsList>
          </Tabs>

          {/* Recipe Details */}
          <div className={styles.recipeDetails}>
            <h4 className={styles.recipeName}>{selectedRecipe.name}</h4>
            <p className={styles.recipeDescription}>{selectedRecipe.description}</p>
            <div className={styles.recipeStats}>
              <span className={styles.statItem}>
                <Coin className={styles.statIcon} />
                Cost: {MOCK.craftingCost} gold
              </span>
              <span className={styles.statItem}>
                <Clock className={styles.statIcon} />
                Duration: {MOCK.craftingDuration}s
              </span>
            </div>
          </div>
        </section>

        {/* Material Requirements */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Material Requirements</h3>
          <div className={styles.materialsContainer}>
            {selectedRecipe.requiredMaterials.map(function (material, index) {
              const available = MOCK.availableMaterials.find(
                (m) => m.materialId === material.materialId
              )
              return (
                <div key={index} className={styles.materialRow}>
                  <span className={styles.materialIcon}>{getMaterialIcon(material.materialId)}</span>
                  <div className={styles.materialInfo}>
                    <span className={styles.materialName}>{material.materialName}</span>
                    <span className={styles.materialQuantity}>
                      Required: {material.quantityRequired}
                    </span>
                  </div>
                  {available ? (
                    <span className={styles.materialAvailable}>
                      Available: {available.quantityAvailable}
                    </span>
                  ) : null}
                  {missingMaterials.find((m) => m.materialId === material.materialId) && (
                    <span className={styles.materialMissing}>
                      Missing: {missingMaterials.find((m) => m.materialId === material.materialId)?.deficitAmount}
                    </span>
                  )}
                </div>
              )
            })}
          </div>
        </section>

        {/* Player Inventory */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Player Inventory</h3>
          <div className={styles.inventoryContainer}>
            {MOCK.availableMaterials.map(function (material, index) {
              const required = selectedRecipe.requiredMaterials.find(
                (r) => r.materialId === material.materialId
              )
              return (
                <div key={index} className={styles.inventoryRow}>
                  <span className={styles.inventoryIcon}>{getMaterialIcon(material.materialId)}</span>
                  <span className={styles.inventoryName}>{material.materialName}</span>
                  <span className={styles.inventoryQuantity}>x{material.quantityAvailable}</span>
                  {required && (
                    <span className={styles.inventoryRequired}>
                      Need: {required.quantityRequired}
                    </span>
                  )}
                </div>
              )
            })}
          </div>
        </section>

        {/* Crafting Controls */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Crafting Controls</h3>
          <div className={styles.controlsContainer}>
            {isCraftingInProgress ? (
              <div className={styles.craftingActive}>
                <Sparkles className={styles.craftingIcon} />
                <span>Crafting in progress...</span>
                <Progress value={progressPercentage} className={styles.progress} />
                <span className={styles.progressText}>{Math.round(progressPercentage)}%</span>
              </div>
            ) : (
              <Button
                onClick={handleStartCrafting}
                disabled={!hasAllMaterials || !canAffordCost}
                className={styles.craftButton}
              >
                <Hammer className={styles.buttonIcon} />
                Start Crafting
              </Button>
            )}

            {isCraftingInProgress && (
              <Button
                onClick={handleCancelCrafting}
                variant='destructive'
                size='sm'
                className={styles.cancelButton}
              >
                <X className={styles.buttonIcon} />
                Cancel
              </Button>
            )}

            {!hasAllMaterials && (
              <Alert className={styles.alertMissing}>
                <AlertTriangle className={styles.alertIcon} />
                <AlertTitle>Missing Materials</AlertTitle>
                <AlertDescription>
                  You need to gather more materials before crafting.
                </AlertDescription>
              </Alert>
            )}

            {canAffordCost === false && (
              <Alert className={styles.alertCost}>
                <AlertTriangle className={styles.alertIcon} />
                <AlertTitle>Insufficient Funds</AlertTitle>
                <AlertDescription>
                  You need more gold to craft this item.
                </AlertDescription>
              </Alert>
            )}
          </div>
        </section>

        {/* Item Preview */}
        <section className={styles.section}>
          <h3 className={styles.sectionTitle}>Item Preview</h3>
          <Card className={styles.previewCard}>
            <CardHeader className={styles.cardHeader}>
              <CardTitle className={styles.previewTitle}>{selectedRecipe.name}</CardTitle>
              <span className={styles.previewCategory}>{selectedRecipe.category.toUpperCase()}</span>
            </CardHeader>
            <CardContent className={styles.cardContent}>
              {Object.entries(selectedRecipe.itemStats).map(function ([statName, statValue]) {
                return (
                  <div key={statName} className={styles.statRow}>
                    <span className={styles.statLabel}>{statName}</span>
                    <span className={styles.statValue}>{statValue}</span>
                  </div>
                )
              })}
            </CardContent>
          </Card>
        </section>

        {/* Feedback System */}
        {successMessage && (
          <section className={styles.section}>
            <Alert className={styles.alertSuccess}>
              <Check className={styles.alertIcon} />
              <AlertTitle>Success!</AlertTitle>
              <AlertDescription>{successMessage}</AlertDescription>
            </Alert>
          </section>
        )}

        {failureReason && (
          <section className={styles.section}>
            <Alert className={styles.alertFailure}>
              <X className={styles.alertIcon} />
              <AlertTitle>Error</AlertTitle>
              <AlertDescription>{failureReason}</AlertDescription>
            </Alert>
          </section>
        )}

        {/* Workbench Layout */}
        <div className={styles.workbenchFooter}>
          <span className={styles.workbenchText}>
            <GiChest className={styles.workbenchIcon} />
            Ancient workbench - Level 1
          </span>
          <span className={styles.workbenchText}>
            <GiFire className={styles.workbenchIcon} />
            Forge temperature: Optimal
          </span>
        </div>
      </div>
    </div>
  )
}

function getCategoryIcon(category: string) {
  switch (category) {
    case "weapons":
      return <Sword className={styles.categoryIcon} />
    case "armor":
      return <Shield className={styles.categoryIcon} />
    case "potions":
      return <Flask className={styles.categoryIcon} />
    case "accessories":
      return <Gem className={styles.categoryIcon} />
    default:
      return <Scroll className={styles.categoryIcon} />
  }
}

function getMaterialIcon(materialId: string) {
  switch (materialId) {
    case "steel_ingot":
    case "iron_ingot":
      return <GiPickaxe className={styles.materialIcon} />
    case "gem_ruby":
    case "gem_emerald":
    case "gem_crystal":
      return <GiRing className={styles.materialIcon} />
    case "leather_strap":
      return <GiArmor className={styles.materialIcon} />
    case "herb_mandrake":
      return <GiPotion className={styles.materialIcon} />
    case "water_spring":
      return <GiWater className={styles.materialIcon} />
    default:
      return <Gem className={styles.materialIcon} />
  }
}
