"use client"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Progress } from "@/components/ui/progress"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Separator } from "@/components/ui/separator"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import { AlertCircle, Anvil, Gem, Hammer, Mountain, Pickaxe, Shield, Star, Sword } from "lucide-react"
import { useState } from "react"
import { GiCrossShield, GiCrystalGrowth, GiPineTree, GiWaterFlask } from "react-icons/gi"
import styles from "./styles/CraftingSkillTreePanel.module.css"

export default function CraftingSkillTreePanel() {
  // ── UI STATE ───────────────────────────────────────────────────────────────
  const [selectedNode, setSelectedNode] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState("skills")
  const [isCrafting, setIsCrafting] = useState<boolean>(false)

  // ── MOCK ───────────────────────────────────────────────────────────────────
  const MOCK = {
    playerCraftingLevel: 5,
    unlockedSkills: ["1", "2", "3", "4", "5"],
    availableSkillNodes: [
      {
        id: "1",
        name: "Basic Smithing",
        description: "Learn to forge simple weapons and armor",
        icon: Hammer,
        prerequisites: [],
        cost: 0,
        isUnlocked: true,
        isAvailable: true,
        xpRequired: 100,
        maxLevel: 5,
      },
      {
        id: "2",
        name: "Advanced Smithing",
        description: "Master complex weapon crafting techniques",
        icon: Anvil,
        prerequisites: ["1"],
        cost: 500,
        isUnlocked: true,
        isAvailable: true,
        xpRequired: 300,
        maxLevel: 5,
      },
      {
        id: "3",
        name: "Mining Expertise",
        description: "Extract rare ores with precision",
        icon: Pickaxe,
        prerequisites: [],
        cost: 200,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 150,
        maxLevel: 5,
      },
      {
        id: "4",
        name: "Alchemy Basics",
        description: "Create simple potions and elixirs",
        icon: GiWaterFlask,
        prerequisites: ["3"],
        cost: 750,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 200,
        maxLevel: 5,
      },
      {
        id: "5",
        name: "Enchanting Arts",
        description: "Infuse items with magical properties",
        icon: Star,
        prerequisites: ["4"],
        cost: 1500,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 400,
        maxLevel: 5,
      },
      {
        id: "6",
        name: "Jewelry Crafting",
        description: "Create precious gemstone adornments",
        icon: Gem,
        prerequisites: ["3"],
        cost: 1000,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 250,
        maxLevel: 5,
      },
      {
        id: "7",
        name: "Leatherworking",
        description: "Craft armor and bags from hides",
        icon: Shield,
        prerequisites: [],
        cost: 300,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 180,
        maxLevel: 5,
      },
      {
        id: "8",
        name: "Woodcarving",
        description: "Shape wood into useful tools and furniture",
        icon: GiPineTree,
        prerequisites: [],
        cost: 250,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 160,
        maxLevel: 5,
      },
      {
        id: "9",
        name: "Blacksmith Mastery",
        description: "Forge legendary weapons of unparalleled power",
        icon: Sword,
        prerequisites: ["2"],
        cost: 3000,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 600,
        maxLevel: 5,
      },
      {
        id: "10",
        name: "Arcane Smithing",
        description: "Combine magic and metal for mystical artifacts",
        icon: GiCrystalGrowth,
        prerequisites: ["5"],
        cost: 2500,
        isUnlocked: false,
        isAvailable: true,
        xpRequired: 700,
        maxLevel: 5,
      },
    ],
    selectedRecipeId: null,
    componentSlots: [
      { slotIndex: 0, materialType: "Iron Ore", quantity: 12 },
      { slotIndex: 1, materialType: "Steel Ingot", quantity: 8 },
      { slotIndex: 2, materialType: "Gold Dust", quantity: 3 },
    ],
    craftingQueue: [
      { id: "1", name: "Iron Sword", status: "Queued", progress: 0, estimatedTime: "5m" },
      { id: "2", name: "Steel Shield", status: "Crafting", progress: 45, estimatedTime: "3m" },
    ],
    inventoryItems: [
      { id: "1", name: "Iron Ore", quantity: 25, icon: Mountain },
      { id: "2", name: "Steel Ingot", quantity: 10, icon: Anvil },
      { id: "3", name: "Gold Dust", quantity: 5, icon: Gem },
      { id: "4", name: "Leather Hide", quantity: 8, icon: Shield },
    ],
  }

  // ── DERIVED ────────────────────────────────────────────────────────────────
  const unlockedNodeCount = MOCK.availableSkillNodes.filter((node) => node.isUnlocked).length
  const availableNodeCount = MOCK.availableSkillNodes.length - unlockedNodeCount
  const totalXpRequired = MOCK.availableSkillNodes.reduce((sum, node) => sum + (node.xpRequired || 0), 0)

  // ── HANDLERS (stubs) ───────────────────────────────────────────────────────
  function handleUnlockNode(nodeId: string) {
    console.log(`Attempting to unlock skill node ${nodeId}`)
  }

  function handleCraftItem(recipeId: string) {
    setIsCrafting(true)
    setTimeout(() => setIsCrafting(false), 3000)
  }

  function handleSelectRecipe(recipeId: string | null) {
    setSelectedNode(recipeId)
  }

  // ── RENDER ─────────────────────────────────────────────────────────────────
  return (
    <div className={styles.panel}>
      {/* HEADER */}
      <div className={styles.header}>
        <div className={styles.titleSection}>
          <h2 className={styles.title}>Crafting Skill GiPineTree </h2>
          <p className={styles.subTitle}>Master the arts of creation · Level {MOCK.playerCraftingLevel}</p>
          <span className={styles.coordinates}>
            {/* {`Skill Mastery: ${unlockedNodeCount}/${availableSkillNodes.length}`} */}
          </span>
        </div>
        <Button
          onClick={() => console.log("Close crafting panel")}
          variant='ghost'
          size='icon'
          className={styles.closeButton}
        >
          <AlertCircle className={styles.closeIcon} />
        </Button>
      </div>

      {/* CONTENT */}
      <div className={styles.content}>
        {/* Tabs Navigation */}
        <Tabs
          value={activeTab}
          onValueChange={setActiveTab}
          className={styles.tabsContainer}
        >
          <TabsList className={styles.tabsList}>
            <TabsTrigger value='skills'>Skills</TabsTrigger>
            <TabsTrigger value='recipes'>Recipes</TabsTrigger>
            <TabsTrigger value='queue'>Queue</TabsTrigger>
          </TabsList>

          {/* Skills Tab */}
          <TabsContent
            value='skills'
            className={styles.tabContent}
          >
            <ScrollArea className={styles.scrollArea}>
              <div className={styles.skillTreeGrid}>
                {MOCK.availableSkillNodes.map(function (node) {
                  return (
                    <TooltipProvider key={node.id}>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <div
                            onClick={() => handleUnlockNode(node.id)}
                            className={`${styles.skillNode} ${node.isUnlocked ? styles.unlocked : node.isAvailable ? styles.available : styles.locked} ${selectedNode === node.id ? styles.selected : ""}`}
                          >
                            <div className={styles.nodeIcon}>
                              <node.icon size={32} />
                            </div>
                            <div className={styles.nodeContent}>
                              <h4 className={styles.nodeName}>{node.name}</h4>
                              <p className={styles.nodeDescription}>{node.description}</p>
                              {node.isUnlocked && (
                                <Badge
                                  variant='secondary'
                                  className={styles.levelBadge}
                                >
                                  Level 1-{node.maxLevel}
                                </Badge>
                              )}
                            </div>
                          </div>
                        </TooltipTrigger>
                        <TooltipContent side='right'>
                          <p>{node.description}</p>
                          {node.prerequisites.length > 0 && (
                            <p className={styles.tooltipPrereq}>
                              Requires:{" "}
                              {node.prerequisites
                                .map((id) => MOCK.availableSkillNodes.find((n) => n.id === id)?.name)
                                .join(", ")}
                            </p>
                          )}
                          {!node.isUnlocked && node.isAvailable && (
                            <div className={styles.costInfo}>
                              <span className={styles.costLabel}>Cost:</span>
                              <span className={styles.costValue}>{node.cost} XP</span>
                            </div>
                          )}
                        </TooltipContent>
                      </Tooltip>
                    </TooltipProvider>
                  )
                })}
              </div>
            </ScrollArea>

            {/* Progress Section */}
            <section className={styles.progressSection}>
              <h3 className={styles.sectionTitle}>Skill Progress</h3>
              <div className={styles.progressContainer}>
                <Progress
                  value={(unlockedNodeCount / MOCK.availableSkillNodes.length) * 100}
                  className={styles.progressBar}
                />
                <span className={styles.progressText}>
                  {unlockedNodeCount} of {MOCK.availableSkillNodes.length} skills unlocked
                </span>
              </div>
            </section>

            {/* Available Materials */}
            <section className={styles.materialsSection}>
              <h3 className={styles.sectionTitle}>Available Materials</h3>
              <div className={styles.materialsGrid}>
                {MOCK.inventoryItems.map(function (item) {
                  return (
                    <TooltipProvider key={item.id}>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <div className={styles.materialCard}>
                            <item.icon size={24} />
                            <span>{item.name}</span>
                            <Badge variant='outline'>{item.quantity}</Badge>
                          </div>
                        </TooltipTrigger>
                      </Tooltip>
                    </TooltipProvider>
                  )
                })}
              </div>
            </section>

            {/* Crafting Slots */}
            <section className={styles.slotsSection}>
              <h3 className={styles.sectionTitle}>Crafting Slots</h3>
              <div className={styles.slotsContainer}>
                {MOCK.componentSlots.map(function (slot) {
                  return (
                    <TooltipProvider key={slot.slotIndex}>
                      <Tooltip>
                        <TooltipTrigger asChild>
                          <div className={styles.craftingSlot}>
                            <span>{slot.materialType}</span>
                            <Badge variant='secondary'>{slot.quantity}</Badge>
                          </div>
                        </TooltipTrigger>
                      </Tooltip>
                    </TooltipProvider>
                  )
                })}
              </div>
            </section>

            {/* Crafting Queue */}
            <section className={styles.queueSection}>
              <h3 className={styles.sectionTitle}>Crafting Queue</h3>
              <div className={styles.queueContainer}>
                {MOCK.craftingQueue.map(function (job) {
                  return (
                    <Card
                      key={job.id}
                      className={styles.queueItem}
                    >
                      <CardContent className={styles.queueContent}>
                        <div className={styles.queueHeader}>
                          <h4>{job.name}</h4>
                          <Badge variant={job.status === "Crafting" ? "default" : "secondary"}>{job.status}</Badge>
                        </div>
                        <Progress
                          value={job.progress}
                          className={styles.queueProgress}
                        />
                        <span className={styles.queueTime}>{job.estimatedTime} remaining</span>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>
            </section>

            {/* Action Buttons */}
            <div className={styles.actionButtons}>
              <Button
                onClick={() => handleCraftItem("1")}
                disabled={isCrafting}
              >
                Craft Item
              </Button>
              <Button
                variant='outline'
                onClick={() => console.log("Open recipe book")}
              >
                Open Recipe Book
              </Button>
            </div>

            {/* Hints */}
            {unlockedNodeCount > 0 && (
              <p className={styles.hintText}>
                You have unlocked {unlockedNodeCount} skills. Continue exploring the tree to master all crafts!
              </p>
            )}
          </TabsContent>

          {/* Recipes Tab */}
          <TabsContent
            value='recipes'
            className={styles.tabContent}
          >
            <ScrollArea className={styles.scrollArea}>
              <div className={styles.recipeGrid}>
                {MOCK.availableSkillNodes.slice(0, 4).map(function (node) {
                  return (
                    <Card
                      key={node.id}
                      className={styles.recipeCard}
                    >
                      <CardHeader>
                        <CardTitle className={styles.recipeName}>{node.name}</CardTitle>
                        <p className={styles.recipeDescription}>{node.description}</p>
                      </CardHeader>
                      <CardContent>
                        <div className={styles.recipeRequirements}>
                          <span>
                            <GiCrossShield size={16} /> {MOCK.inventoryItems[0]?.name}: 5
                          </span>
                          <span>
                            <Gem size={16} /> {MOCK.inventoryItems[2]?.name}: 3
                          </span>
                        </div>
                        <Button
                          onClick={() => handleSelectRecipe(node.id)}
                          variant='outline'
                          className={styles.recipeButton}
                        >
                          View Recipe
                        </Button>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>
            </ScrollArea>
          </TabsContent>

          {/* Queue Tab */}
          <TabsContent
            value='queue'
            className={styles.tabContent}
          >
            <ScrollArea className={styles.scrollArea}>
              <div className={styles.queueFullList}>
                {MOCK.craftingQueue.map(function (job) {
                  return (
                    <Card
                      key={job.id}
                      className={styles.queueItemFull}
                    >
                      <CardContent className={styles.queueContentFull}>
                        <div className={styles.queueHeaderFull}>
                          <h4>{job.name}</h4>
                          <Badge variant={job.status === "Crafting" ? "default" : "secondary"}>{job.status}</Badge>
                        </div>
                        <Progress
                          value={job.progress}
                          className={styles.queueProgressFull}
                        />
                        <span className={styles.queueTimeFull}>{job.estimatedTime} remaining</span>
                      </CardContent>
                    </Card>
                  )
                })}
              </div>

              {/* Queue Controls */}
              <div className={styles.queueControls}>
                <Button
                  variant='outline'
                  onClick={() => console.log("Cancel all queue")}
                >
                  Cancel All
                </Button>
                <Button
                  variant='outline'
                  onClick={() => console.log("Clear completed jobs")}
                >
                  Clear Completed
                </Button>
              </div>

              {/* Hints */}
              {MOCK.craftingQueue.length === 0 && <p className={styles.emptyStateText}>No items in crafting queue</p>}
            </ScrollArea>
          </TabsContent>
        </Tabs>
      </div>

      {/* Footer */}
      <footer className={styles.footer}>
        <Separator className={styles.separator} />
        <div className={styles.footerContent}>
          <span>Crafting Skill GiPineTree </span>
          <span>Mastery Level: {MOCK.playerCraftingLevel}</span>
          <span>{/* {unlockedNodeCount}/{availableSkillNodes.length} Skills Unlocked/ */}</span>
        </div>
      </footer>
    </div>
  )
}
