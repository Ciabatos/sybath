"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { TooltipProvider, Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import { Slider } from "@/components/ui/slider"
import { Switch } from "@/components/ui/switch"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { AlertCircle, ArrowRight, Clock, Flame, Hand, Loader, Sparkles, Sunrise, Tent, UserCheck, Search, Filter, Settings, Info, Check, X, Plus, Minus, Refresh, ChevronRight, Gem, Coin, Star } from "lucide-react"
import {
  GiBelt,
  GiBigDiamondRing,
  GiChestArmor,
  GiCrestedHelmet,
  GiCrystalBall,
  GiDropWeapon,
  GiEmeraldNecklace,
  GiEyeTarget,
  GiSteeltoeBoots,
} from "react-icons/gi"
import { useState } from "react"
import styles from "./styles/CraftingSkillTree.module.css"

export default function CraftingSkillTree() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null)
  const [craftingMode, setCraftingMode] = useState<boolean>(false)
  const [currentRecipeId, setCurrentRecipeId] = useState<string | null>(null)
  const [unlockStatus, setUnlockStatus] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState<string>("")
  const [filterType, setFilterType] = useState<string>("all")

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    skillTreeData: [
      { id: "node_1", name: "Basic Smithing", type: "weapons", branchId: "weapons", iconKey: "hammer", description: "Learn to forge basic weapons from raw materials.", unlockCost: 0, xpRequired: 100, prerequisites: [] },
      { id: "node_2", name: "Advanced Forging", type: "weapons", branchId: "weapons", iconKey: "sword", description: "Master the art of creating superior weapons.", unlockCost: 500, xpRequired: 300, prerequisites: ["node_1"] },
      { id: "node_3", name: "Enchanted Blades", type: "enchantments", branchId: "enchantments", iconKey: "sparkles", description: "Infuse weapons with magical properties.", unlockCost: 1000, xpRequired: 500, prerequisites: ["node_2"] },
      { id: "node_4", name: "Leatherworking", type: "armor", branchId: "armor", iconKey: "shield", description: "Craft protective gear from leather and hide.", unlockCost: 0, xpRequired: 100, prerequisites: [] },
      { id: "node_5", name: "Plate Mastery", type: "armor", branchId: "armor", iconKey: "ChestArmor", description: "Forge heavy armor from refined metals.", unlockCost: 750, xpRequired: 400, prerequisites: ["node_1"] },
      { id: "node_6", name: "Potion Brewing", type: "potions", branchId: "potions", iconKey: "flask", description: "Create magical potions for combat and healing.", unlockCost: 250, xpRequired: 200, prerequisites: [] },
      { id: "node_7", name: "Elixir Mastery", type: "potions", branchId: "potions", iconKey: "gem", description: "Craft rare elixirs with powerful effects.", unlockCost: 1500, xpRequired: 600, prerequisites: ["node_6"] },
      { id: "node_8", name: "Runesmithing", type: "enchantments", branchId: "enchantments", iconKey: "scroll", description: "Carve ancient runes into magical items.", unlockCost: 2000, xpRequired: 700, prerequisites: ["node_3"] },
      { id: "node_9", name: "Jewelry Crafting", type: "misc", branchId: "misc", iconKey: "BigDiamondRing", description: "Create ornate jewelry and accessories.", unlockCost: 500, xpRequired: 250, prerequisites: [] },
      { id: "node_10", name: "Mystic Artifacts", type: "enchantments", branchId: "enchantments", iconKey: "CrystalBall", description: "Forge legendary artifacts of immense power.", unlockCost: 3000, xpRequired: 1000, prerequisites: ["node_8"] },
    ],

    unlockedNodes: ["node_1", "node_4", "node_6"],

    currentRecipe: {
      recipeId: "recipe_potion_health",
      name: "Health Elixir",
      description: "Restores 50 HP and grants minor regeneration.",
      requiredIngredients: [
        { ingredientId: "herb_mandrake", quantity: 2, qualityTier: 3 },
        { ingredientId: "water_holy", quantity: 1, qualityTier: 2 },
        { ingredientId: "gem_ruby", quantity: 1, qualityTier: 4 },
      ],
      successChance: 75,
      craftingTime: 120,
    },

    ingredientSlots: [
      { slotIndex: 0, ingredientId: null, quantity: 0, isValidated: false },
      { slotIndex: 1, ingredientId: null, quantity: 0, isValidated: false },
      { slotIndex: 2, ingredientId: null, quantity: 0, isValidated: false },
    ],

    availableIngredients: {
      herb_mandrake: { quantity: 5, qualityTiers: [1, 2, 3] },
      water_holy: { quantity: 3, qualityTiers: [1, 2, 3, 4] },
      gem_ruby: { quantity: 2, qualityTiers: [3, 4, 5] },
      wood_oak: { quantity: 10, qualityTiers: [1, 2, 3] },
      metal_iron: { quantity: 8, qualityTiers: [1, 2, 3, 4] },
    },

    progressXP: {
      weapons: { currentXP: 150, maxXP: 500, level: 1 },
      armor: { currentXP: 80, maxXP: 400, level: 1 },
      potions: { currentXP: 250, maxXP: 600, level: 2 },
      enchantments: { currentXP: 0, maxXP: 1000, level: 1 },
      misc: { currentXP: 30, maxXP: 300, level: 1 },
    },

    unlockStatus: "locked",
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const selectedNode = MOCK.skillTreeData.find((node) => node.id === selectedNodeId) || null
  const filteredIngredients = Object.keys(MOCK.availableIngredients).filter(
    (id) => {
      if (!searchQuery) return true
      const ingredientName = id.replace("_", " ").toLowerCase()
      return ingredientName.includes(searchQuery.toLowerCase())
    }
  )

  const progressPercentages = Object.entries(MOCK.progressXP).map(([branchId, data]) => ({
    branchId,
    percentage: Math.round((data.currentXP / data.maxXP) * 100),
  }))

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleNodeClick(nodeId: string) {
    setSelectedNodeId(nodeId)
    setUnlockStatus("unlocked")
  }

  function handleIngredientSelect(ingredientId: string, slotIndex: number) {
    const ingredient = MOCK.availableIngredients[ingredientId]
    if (ingredient && ingredient.quantity > 0) {
      const newSlots = [...MOCK.ingredientSlots]
      newSlots[slotIndex] = {
        slotIndex,
        ingredientId,
        quantity: Math.min(ingredient.quantity, 5),
        isValidated: true,
      }
      setIngredientSlots(newSlots)
    }
  }

  function handleRemoveIngredient(slotIndex: number) {
    const newSlots = [...MOCK.ingredientSlots]
    newSlots[slotIndex] = { slotIndex, ingredientId: null, quantity: 0, isValidated: false }
    setIngredientSlots(newSlots)
  }

  function handleCraft() {
    console.log("Crafting recipe:", MOCK.currentRecipe?.recipeId)
    setUnlockStatus("unlocked")
  }

  function handleResetSlots() {
    const newSlots = MOCK.ingredientSlots.map((slot, index) => ({
      slotIndex: index,
      ingredientId: null,
      quantity: 0,
      isValidated: false,
    }))
    setIngredientSlots(newSlots)
  }

  function handleFilterChange(type: string) {
    setFilterType(type)
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <TooltipProvider>
      <div className={styles.panel}>
        {/* HEADER */}
        <div className={styles.header}>
          <div className={styles.titleSection}>
            <h2 className={styles.title}>Crafting Skill Tree</h2>
            <p className={styles.subTitle}>Master the ancient arts of creation · {MOCK.skillTreeData.length} skills available</p>
            <span className={styles.coordinates}>{unlockStatus === "unlocked" ? "✨ Mastery Unlocked" : "🔒 Journey Begins"}</span>
          </div>
          <Button onClick={() => setCraftingMode(!craftingMode)} variant="outline">
            {craftingMode ? (
              <>
                <X className={styles.closeIcon} /> Exit Crafting Mode
              </>
            ) : (
              <>
                <Plus className={styles.closeIcon} /> Enter Crafting Mode
              </>
            )}
          </Button>
        </div>

        {/* CONTENT */}
        <div className={styles.content}>
          {/* Main Tabs */}
          <Tabs defaultValue="tree" className={styles.tabsContainer}>
            <TabsList className={styles.tabsList}>
              <TabsTrigger value="tree">Skill Tree</TabsTrigger>
              <TabsTrigger value="crafting">Crafting Workshop</TabsTrigger>
              <TabsTrigger value="progress">Progress</TabsTrigger>
            </TabsList>

            {/* Skill Tree Tab */}
            <TabsContent value="tree" className={styles.tabContent}>
              <div className={styles.treeContainer}>
                <ScrollArea className={styles.scrollArea}>
                  <div className={styles.treeCanvas}>
                    {/* Branch Categories */}
                    <div className={styles.branchCategory}>
                      <h3 className={styles.branchTitle}>Weapons</h3>
                      {MOCK.skillTreeData.filter((node) => node.type === "weapons").map(function (node) {
                        return (
                          <Tooltip key={node.id}>
                            <TooltipTrigger asChild>
                              <div
                                onClick={() => handleNodeClick(node.id)}
                                className={`${styles.skillNode} ${MOCK.unlockedNodes.includes(node.id) ? styles.unlocked : ""}`}
                              >
                                {MOCK.unlockedNodes.includes(node.id) ? (
                                  <>
                                    <span className={styles.nodeIcon}>{node.iconKey}</span>
                                    <div className={styles.nodeInfo}>
                                      <span className={styles.nodeName}>{node.name}</span>
                                      <Badge variant="outline" className={styles.xpBadge}>
                                        {Math.round((MOCK.progressXP[node.branchId]?.currentXP || 0) / MOCK.progressXP[node.branchId]?.maxXP * 100)}% XP
                                      </Badge>
                                    </div>
                                  </>
                                ) : (
                                  <span className={styles.lockedIcon}>🔒</span>
                                )}
                              </div>
                            </TooltipTrigger>
                            <TooltipContent>
                              <p>{node.description}</p>
                              <p className={styles.tooltipCost}>{node.unlockCost} XP required</p>
                            </TooltipContent>
                          </Tooltip>
                        )
                      })}
                    </div>

                    {/* Armor Branch */}
                    <div className={styles.branchCategory}>
                      <h3 className={styles.branchTitle}>Armor</h3>
                      {MOCK.skillTreeData.filter((node) => node.type === "armor").map(function (node) {
                        return (
                          <Tooltip key={node.id}>
                            <TooltipTrigger asChild>
                              <div
                                onClick={() => handleNodeClick(node.id)}
                                className={`${styles.skillNode} ${MOCK.unlockedNodes.includes(node.id) ? styles.unlocked : ""}`}
                              >
                                {MOCK.unlockedNodes.includes(node.id) ? (
                                  <>
                                    <span className={styles.nodeIcon}>{node.iconKey}</span>
                                    <div className={styles.nodeInfo}>
                                      <span className={styles.nodeName}>{node.name}</span>
                                      <Badge variant="outline" className={styles.xpBadge}>
                                        {Math.round((MOCK.progressXP[node.branchId]?.currentXP || 0) / MOCK.progressXP[node.branchId]?.maxXP * 100)}% XP
                                      </Badge>
                                    </div>
                                  </>
                                ) : (
                                  <span className={styles.lockedIcon}>🔒</span>
                                )}
                              </div>
                            </TooltipTrigger>
                            <TooltipContent>
                              <p>{node.description}</p>
                              <p className={styles.tooltipCost}>{node.unlockCost} XP required</p>
                            </TooltipContent>
                          </Tooltip>
                        )
                      })}
                    </div>

                    {/* Potions Branch */}
                    <div className={styles.branchCategory}>
                      <h3 className={styles.branchTitle}>Potions</h3>
                      {MOCK.skillTreeData.filter((node) => node.type === "potions").map(function (node) {
                        return (
                          <Tooltip key={node.id}>
                            <TooltipTrigger asChild>
                              <div
                                onClick={() => handleNodeClick(node.id)}
                                className={`${styles.skillNode} ${MOCK.unlockedNodes.includes(node.id) ? styles.unlocked : ""}`}
                              >
                                {MOCK.unlockedNodes.includes(node.id) ? (
                                  <>
                                    <span className={styles.nodeIcon}>{node.iconKey}</span>
                                    <div className={styles.nodeInfo}>
                                      <span className={styles.nodeName}>{node.name}</span>
                                      <Badge variant="outline" className={styles.xpBadge}>
                                        {Math.round((MOCK.progressXP[node.branchId]?.currentXP || 0) / MOCK.progressXP[node.branchId]?.maxXP * 100)}% XP
                                      </Badge>
                                    </div>
                                  </>
                                ) : (
                                  <span className={styles.lockedIcon}>🔒</span>
                                )}
                              </div>
                            </TooltipTrigger>
                            <TooltipContent>
                              <p>{node.description}</p>
                              <p className={styles.tooltipCost}>{node.unlockCost} XP required</p>
                            </TooltipContent>
                          </Tooltip>
                        )
                      })}
                    </div>

                    {/* Enchantments Branch */}
                    <div className={styles.branchCategory}>
                      <h3 className={styles.branchTitle}>Enchantments</h3>
                      {MOCK.skillTreeData.filter((node) => node.type === "enchantments").map(function (node) {
                        return (
                          <Tooltip key={node.id}>
                            <TooltipTrigger asChild>
                              <div
                                onClick={() => handleNodeClick(node.id)}
                                className={`${styles.skillNode} ${MOCK.unlockedNodes.includes(node.id) ? styles.unlocked : ""}`}
                              >
                                {MOCK.unlockedNodes.includes(node.id) ? (
                                  <>
                                    <span className={styles.nodeIcon}>{node.iconKey}</span>
                                    <div className={styles.nodeInfo}>
                                      <span className={styles.nodeName}>{node.name}</span>
                                      <Badge variant="outline" className={styles.xpBadge}>
                                        {Math.round((MOCK.progressXP[node.branchId]?.currentXP || 0) / MOCK.progressXP[node.branchId]?.maxXP * 100)}% XP
                                      </Badge>
                                    </div>
                                  </>
                                ) : (
                                  <span className={styles.lockedIcon}>🔒</span>
                                )}
                              </div>
                            </TooltipTrigger>
                            <TooltipContent>
                              <p>{node.description}</p>
                              <p className={styles.tooltipCost}>{node.unlockCost} XP required</p>
                            </TooltipContent>
                          </Tooltip>
                        )
                      })}
                    </div>

                    {/* Misc Branch */}
                    <div className={styles.branchCategory}>
                      <h3 className={styles.branchTitle}>Miscellaneous</h3>
                      {MOCK.skillTreeData.filter((node) => node.type === "misc").map(function (node) {
                        return (
                          <Tooltip key={node.id}>
                            <TooltipTrigger asChild>
                              <div
                                onClick={() => handleNodeClick(node.id)}
                                className={`${styles.skillNode} ${MOCK.unlockedNodes.includes(node.id) ? styles.unlocked : ""}`}
                              >
                                {MOCK.unlockedNodes.includes(node.id) ? (
                                  <>
                                    <span className={styles.nodeIcon}>{node.iconKey}</span>
                                    <div className={styles.nodeInfo}>
                                      <span className={styles.nodeName}>{node.name}</span>
                                      <Badge variant="outline" className={styles.xpBadge}>
                                        {Math.round((MOCK.progressXP[node.branchId]?.currentXP || 0) / MOCK.progressXP[node.branchId]?.maxXP * 100)}% XP
                                      </Badge>
                                    </div>
                                  </>
                                ) : (
                                  <span className={styles.lockedIcon}>🔒</span>
                                )}
                              </div>
                            </TooltipTrigger>
                            <TooltipContent>
                              <p>{node.description}</p>
                              <p className={styles.tooltipCost}>{node.unlockCost} XP required</p>
                            </TooltipContent>
                          </Tooltip>
                        )
                      })}
                    </div>

                    {/* Connections */}
                    {MOCK.skillTreeData.map(function (node) {
                      if (node.prerequisites.length > 0) {
                        return (
                          <div key={node.id + "_connection"} className={styles.connection}>
                            <ArrowRight className={styles.connectionIcon} />
                          </div>
                        )
                      }
                      return null
                    })}
                  </div>
                </ScrollArea>
              </div>

              {/* Progress Tracker */}
              <div className={styles.progressSection}>
                <h3 className={styles.sectionTitle}>Branch Mastery</h3>
                {Object.entries(MOCK.progressXP).map(function ([branchId, data]) {
                  return (
                    <Card key={branchId} className={styles.progressCard}>
                      <CardHeader className={styles.progressHeader}>
                        <CardTitle className={styles.branchName}>{branchId}</CardTitle>
                        <span className={styles.levelIndicator}>Level {data.level}</span>
                      </CardHeader>
                      <CardContent className={styles.progressContent}>
                        <div className={styles.xpBarContainer}>
                          <Progress value={(data.currentXP / data.maxXP) * 100} className={styles.xpProgressBar} />
                          <span className={styles.xpText}>{Math.round((data.currentXP / data.maxXP) * 100)}% XP</span>
                        </div>
                        <div className={styles.nextLevelInfo}>
                          <Clock className={styles.clockIcon} />
                          <span>{data.maxXP - data.currentXP} XP to next level</span>
                        </div>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>
            </TabsContent>

            {/* Crafting Workshop Tab */}
            <TabsContent value="crafting" className={styles.tabContent}>
              <div className={styles.craftingWorkspace}>
                {/* Recipe Viewer */}
                <Card className={styles.recipeViewer}>
                  <CardHeader className={styles.recipeHeader}>
                    <CardTitle className={styles.recipeName}>{MOCK.currentRecipe?.name || "Select a Recipe"}</CardTitle>
                    <Badge variant="outline" className={styles.recipeType}>
                      {MOCK.currentRecipe?.description}
                    </Badge>
                  </CardHeader>
                  <CardContent className={styles.recipeContent}>
                    {/* Ingredient Slots */}
                    <div className={styles.ingredientSlotsContainer}>
                      {MOCK.ingredientSlots.map(function (slot) {
                        const ingredient = slot.ingredientId ? MOCK.availableIngredients[slot.ingredientId] : null
                        return (
                          <div key={slot.slotIndex} className={styles.ingredientSlot}>
                            <div className={styles.slotIcon}>{ingredient ? "🧪" : "+"}</div>
                            {ingredient ? (
                              <>
                                <span className={styles.slotName}>{slot.ingredientId.replace("_", " ")}</span>
                                <Badge variant="outline" className={styles.quantityBadge}>x{slot.quantity}</Badge>
                                <Button
                                  onClick={() => handleRemoveIngredient(slot.slotIndex)}
                                  variant="ghost"
                                  size="icon"
                                  className={styles.removeButton}
                                >
                                  <X className={styles.removeIcon} />
                                </Button>
                              </>
                            ) : (
                              <>
                                <span className={styles.emptySlot}>Empty Slot</span>
                                <Select onValueChange={(value) => handleIngredientSelect(value, slot.slotIndex)}>
                                  <SelectTrigger className={styles.selectTrigger}>
                                    <SelectValue placeholder="Select ingredient" />
                                  </SelectTrigger>
                                  <SelectContent>
                                    {Object.keys(MOCK.availableIngredients).map(function (ingredientId) {
                                      return (
                                        <SelectItem key={ingredientId} value={ingredientId}>
                                          {ingredientId.replace("_", " ")} ({MOCK.availableIngredients[ingredientId].quantity})
                                        </SelectItem>
                                      )
                                    })}
                                  </SelectContent>
                                </Select>
                              </>
                            )}
                          </div>
                        )
                      })}
                    </div>

                    {/* Recipe Stats */}
                    <div className={styles.recipeStats}>
                      <div className={styles.statRow}>
                        <span className={styles.statLabel}>Success Chance:</span>
                        <Badge variant="outline" className={styles.successChance}>
                          {MOCK.currentRecipe?.successChance}%
                        </Badge>
                      </div>
                      <div className={styles.statRow}>
                        <span className={styles.statLabel}>Crafting Time:</span>
                        <Clock className={styles.clockIcon} />
                        <span>{MOCK.currentRecipe?.craftingTime}s</span>
                      </div>
                    </div>

                    {/* Craft Button */}
                    <Button onClick={handleCraft} className={styles.craftButton}>
                      <Sparkles className={styles.craftIcon} />
                      Craft Item
                    </Button>
                  </CardContent>
                </Card>

                {/* Resource Inventory */}
                <div className={styles.resourceInventory}>
                  <div className={styles.inventoryHeader}>
                    <h3 className={styles.sectionTitle}>Available Materials</h3>
                    <div className={styles.inventoryControls}>
                      <Input
                        placeholder="Search materials..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className={styles.searchInput}
                      />
                      <Button variant="outline" size="icon">
                        <Filter className={styles.filterIcon} />
                      </Button>
                    </div>
                  </div>

                  <ScrollArea className={styles.scrollArea}>
                    <div className={styles.inventoryGrid}>
                      {filteredIngredients.map(function (ingredientId) {
                        const ingredient = MOCK.availableIngredients[ingredientId]
                        return (
                          <Card key={ingredientId} className={styles.inventoryItem}>
                            <CardContent className={styles.inventoryContent}>
                              <Badge variant="outline" className={styles.ingredientIcon}>🧪</Badge>
                              <div className={styles.ingredientInfo}>
                                <span className={styles.ingredientName}>{ingredientId.replace("_", " ")}</span>
                                <span className={styles.quantityDisplay}>{ingredient.quantity} available</span>
                              </div>
                              <Button
                                onClick={() => handleIngredientSelect(ingredientId, 0)}
                                variant="outline"
                                size="sm"
                                className={styles.addSlotButton}
                              >
                                Add to Recipe
                              </Button>
                            </CardContent>
                          </Card>
                        )
                      })}
                    </div>
                  </ScrollArea>
                </div>
              </div>
            </TabsContent>

            {/* Progress Tab */}
            <TabsContent value="progress" className={styles.tabContent}>
              <div className={styles.progressDashboard}>
                <h2 className={styles.dashboardTitle}>Crafting Progress</h2>

                {Object.entries(MOCK.progressXP).map(function ([branchId, data]) {
                  return (
                    <Card key={branchId} className={styles.progressCard}>
                      <CardHeader className={styles.progressHeader}>
                        <div className={styles.branchInfo}>
                          <span className={styles.branchName}>{branchId}</span>
                          <Badge variant="outline" className={styles.levelBadge}>Level {data.level}</Badge>
                        </div>
                        <Sparkles className={styles.sparkleIcon} />
                      </CardHeader>
                      <CardContent className={styles.progressContent}>
                        <div className={styles.xpBarContainer}>
                          <Progress value={(data.currentXP / data.maxXP) * 100} className={styles.xpProgressBar} />
                          <span className={styles.xpText}>{Math.round((data.currentXP / data.maxXP) * 100)}% Complete</span>
                        </div>

                        <div className={styles.progressDetails}>
                          <div className={styles.detailRow}>
                            <span className={styles.detailLabel}>Current XP:</span>
                            <span className={styles.detailValue}>{data.currentXP}</span>
                          </div>
                          <div className={styles.detailRow}>
                            <span className={styles.detailLabel}>Max XP for Level:</span>
                            <span className={styles.detailValue}>{data.maxXP}</span>
                          </div>
                          <div className={styles.detailRow}>
                            <span className={styles.detailLabel}>Remaining to Next Level:</span>
                            <span className={styles.detailValue}>{data.maxXP - data.currentXP} XP</span>
                          </div>
                        </div>

                        <Alert variant="default" className={styles.unlockAlert}>
                          <Info className={styles.alertIcon} />
                          <AlertTitle>Unlock Requirements</AlertTitle>
                          <AlertDescription>
                            Complete {Math.round((data.maxXP - data.currentXP) / 10)} more skill nodes to unlock advanced techniques.
                          </AlertDescription>
                        </Alert>
                      </CardContent>
                    </Card>
                  )
                })}

                {/* Summary Stats */}
                <div className={styles.summaryStats}>
                  <h3 className={styles.sectionTitle}>Overall Statistics</h3>
                  <div className={styles.statsGrid}>
                    <div className={styles.statBox}>
                      <Gem className={styles.statIcon} />
                      <span className={styles.statValue}>{MOCK.unlockedNodes.length}</span>
                      <span className={styles.statLabel}>Skills Unlocked</span>
                    </div>
                    <div className={styles.statBox}>
                      <Coin className={styles.statIcon} />
                      <span className={styles.statValue}>1,250</span>
                      <span className={styles.statLabel}>XP Earned</span>
                    </div>
                    <div className={styles.statBox}>
                      <Star className={styles.statIcon} />
                      <span className={styles.statValue}>3</span>
                      <span className={styles.statLabel}>Branches Mastered</span>
                    </div>
                  </div>
                </div>
              </div>
            </TabsContent>
          </Tabs>
        </div>

        {/* Footer */}
        <footer className={styles.footer}>
          <p>Mastery awaits those who dare to craft.</p>
          <span className={styles.credits}>Ancient Grimoire v1.0</span>
        </footer>
      </div>
    </TooltipProvider>
  )
}
