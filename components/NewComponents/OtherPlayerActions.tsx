"use client"

import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip"
import {
  Anchor,
  Anvil,
  Backpack,
  Binoculars,
  Castle,
  Crown,
  FlaskConical,
  Gift,
  Handshake,
  Heart,
  MapPin,
  Shield,
  Sparkles,
  Sword,
  Trophy,
  UserPlus,
  Users,
  Zap
} from "lucide-react"
import { useState } from "react"
import styles from "./styles/OtherPlayerActions.module.css"

export default function OtherPlayerActions() {
  const [activeTab, setActiveTab] = useState<"actions" | "inventory" | "squad">("actions")
  const [selectedPlayer, setSelectedPlayer] = useState<number | null>(null)

  const MOCK = {
    title: "Other Players",
    tabs: [
      { id: "actions", label: "Actions", icon: Sword },
      { id: "inventory", label: "Inventory", icon: Backpack },
      { id: "squad", label: "Squad", icon: Users },
    ],
    players: [
      {
        id: 1,
        name: "Sir Valerius",
        title: "Knight Commander",
        level: 24,
        reputation: 85,
        location: "Castle Blackwood",
        coordinates: { x: 12, y: 7 },
        online: true,
        faction: "Order of the Silver Hand",
        resources: [
          { icon: "Coins", value: 3450 },
          { icon: "Heart", value: 89 },
          { icon: "FlaskConical", value: 120 },
          { icon: "Gem", value: 45 },
        ],
        stats: [
          { icon: "Sword", value: 78, type: "attack" },
          { icon: "Shield", value: 92, type: "defense" },
          { icon: "Flame", value: 34, type: "magic" },
        ],
        availableActions: [
          { id: "trade", label: "Trade Goods", icon: Gift, cost: { gold: 100 } },
          { id: "inviteSquad", label: "Invite to Squad", icon: UserPlus, cost: {} },
          { id: "questOffer", label: "Quest Offer", icon: Crown, cost: { reputation: 5 } },
          { id: "alliance", label: "Form Alliance", icon: Handshake, cost: { gold: 200 } },
        ],
      },
      {
        id: 2,
        name: "Lady Elara",
        title: "Mystic Seeress",
        level: 19,
        reputation: 67,
        location: "Crystal Spire",
        coordinates: { x: 8, y: 15 },
        online: true,
        faction: "Circle of Arcane",
        resources: [
          { icon: "Coins", value: 2100 },
          { icon: "Heart", value: 65 },
          { icon: "FlaskConical", value: 89 },
          { icon: "Gem", value: 78 },
        ],
        stats: [
          { icon: "Sword", value: 45, type: "attack" },
          { icon: "Shield", value: 62, type: "defense" },
          { icon: "Sparkles", value: 95, type: "magic" },
        ],
        availableActions: [
          { id: "trade", label: "Trade Goods", icon: Gift, cost: { gold: 100 } },
          { id: "inviteSquad", label: "Invite to Squad", icon: UserPlus, cost: {} },
          { id: "questOffer", label: "Quest Offer", icon: Crown, cost: { reputation: 3 } },
          { id: "magicService", label: "Magic Service", icon: Zap, cost: { gold: 150 } },
        ],
      },
      {
        id: 3,
        name: "Thorn the Black",
        title: "Shadow Assassin",
        level: 28,
        reputation: 42,
        location: "Darkwood Keep",
        coordinates: { x: 19, y: 11 },
        online: false,
        faction: "Order of Shadows",
        resources: [
          { icon: "Coins", value: 5600 },
          { icon: "Heart", value: 45 },
          { icon: "FlaskConical", value: 200 },
          { icon: "Gem", value: 120 },
        ],
        stats: [
          { icon: "Sword", value: 98, type: "attack" },
          { icon: "Shield", value: 35, type: "defense" },
          { icon: "Skull", value: 72, type: "magic" },
        ],
        availableActions: [
          { id: "trade", label: "Trade Goods", icon: Gift, cost: { gold: 100 } },
          { id: "inviteSquad", label: "Invite to Squad", icon: UserPlus, cost: {} },
          { id: "questOffer", label: "Quest Offer", icon: Crown, cost: { reputation: 8 } },
          { id: "mercenary", label: "Hire Mercenary", icon: Sword, cost: { gold: 300 } },
        ],
      },
    ],
  }

  function handleAction(playerId: number, actionId: string) {}

  function handleInspectPlayer(playerId: number) {}

  return (
    <div className={styles.window}>
      <div className={styles.titleBar}>
        <div className={styles.titleContainer}>
          <Crown size={24} />
          <h2 className={styles.title}>{MOCK.title}</h2>
        </div>
        <div className={styles.playerCount}>
          <Users size={16} />
          {MOCK.players.length} Players
        </div>
      </div>

      <div className={styles.content}>
        <div className={styles.tabsContainer}>
          {MOCK.tabs.map((tab) => (
            <button
              key={tab.id}
              className={`${styles.tab} ${activeTab === tab.id ? styles.active : ""}`}
              onClick={() => setActiveTab(tab.id as typeof activeTab)}
            >
              <tab.icon size={18} />
              {tab.label}
            </button>
          ))}
        </div>

        <div className={styles.playersList}>
          {MOCK.players.map((player) => (
            <div
              key={player.id}
              className={`${styles.playerCard} ${selectedPlayer === player.id ? styles.selected : ""}`}
              onClick={() => setSelectedPlayer(player.id)}
            >
              <div className={styles.playerHeader}>
                <div className={styles.avatarContainer}>
                  <div className={styles.avatar}>
                    {player.online ? <span className={styles.statusDot} /> : <span className={styles.statusDot} />}
                    <UserPlus size={28} />
                  </div>
                </div>

                <div className={styles.playerInfo}>
                  <div className={styles.playerNameRow}>
                    <h3 className={styles.playerName}>{player.name}</h3>
                    {player.online && <Badge>Online</Badge>}
                  </div>

                  <div className={styles.playerTitle}>{player.title}</div>

                  <div className={styles.playerMeta}>
                    <span className={styles.levelBadge}>
                      <Crown size={12} />
                      Lvl {player.level}
                    </span>
                    <span className={styles.factionBadge}>
                      <Castle size={10} />
                      {player.faction}
                    </span>
                  </div>

                  <div className={styles.locationInfo}>
                    <MapPin size={12} />
                    {player.location}
                    <span className={styles.coordinates}>
                      ({player.coordinates.x}, {player.coordinates.y})
                    </span>
                  </div>
                </div>

                <Tooltip>
                  <TooltipTrigger asChild>
                    <button className={styles.reputationBadge}>
                      <Trophy size={14} />
                      {player.reputation}
                    </button>
                  </TooltipTrigger>
                  <TooltipContent>Reputation</TooltipContent>
                </Tooltip>
              </div>

              <div className={styles.resourcesRow}>
                {player.resources.map((resource) => (
                  <span
                    key={resource.icon}
                    className={styles.resourceItem}
                  >
                    <resource.icon />
                    {resource.value.toLocaleString()}
                  </span>
                ))}
              </div>

              <div className={styles.statsRow}>
                {player.stats.map((stat, index) => (
                  <Tooltip key={index}>
                    <TooltipTrigger asChild>
                      <button className={styles.statItem}>
                        <stat.icon />
                        <span className={styles.statValue}>{stat.value}</span>
                        {stat.type === "attack" && <Sword size={10} />}
                        {stat.type === "defense" && <Shield size={10} />}
                        {stat.type === "magic" && <Sparkles size={10} />}
                      </button>
                    </TooltipTrigger>
                    <TooltipContent>
                      <p>{stat.icon}</p>
                      <p className='capitalize'>{stat.type}</p>
                      <p>{stat.value}</p>
                    </TooltipContent>
                  </Tooltip>
                ))}
              </div>

              <div className={styles.actionsRow}>
                {player.availableActions.map((action) => (
                  <button
                    key={action.id}
                    className={`${styles.actionButton} ${activeTab === "actions" ? styles.visible : ""}`}
                    onClick={() => handleAction(player.id, action.id)}
                  >
                    <action.icon size={16} />
                    {action.label}
                    {Object.keys(action.cost).length > 0 && (
                      <span className={styles.actionCost}>
                        {Object.entries(action.cost)
                          .map(([key, value]) => {
                            if (key === "gold") return `${value}g`
                            if (key === "reputation") return `${value} rep`
                            return ""
                          })
                          .filter(Boolean)
                          .join(" + ")}
                      </span>
                    )}
                  </button>
                ))}
              </div>

              <div className={styles.quickActions}>
                <Button
                  variant='ghost'
                  size='sm'
                  onClick={() => handleInspectPlayer(player.id)}
                >
                  Inspect
                </Button>
                {player.online && (
                  <>
                    <Button
                      variant='ghost'
                      size='sm'
                    >
                      Message
                    </Button>
                    <Button
                      variant='ghost'
                      size='sm'
                    >
                      View Map
                    </Button>
                  </>
                )}
              </div>
            </div>
          ))}
        </div>

        {selectedPlayer === null && (
          <div className={styles.emptyState}>
            <Users size={48} />
            <h3>Select a Player</h3>
            <p>Click on any player card to view their details and available actions</p>
          </div>
        )}

        {selectedPlayer !== null && (
          <div className={styles.detailsPanel}>
            <div className={styles.panelHeader}>
              <Anvil size={18} />
              <span>Player Details</span>
            </div>

            <div className={styles.detailRow}>
              <Binoculars size={16} />
              <span>Full Name:</span>
              <strong>{MOCK.players.find((p) => p.id === selectedPlayer)?.name}</strong>
            </div>

            <div className={styles.detailRow}>
              <Castle size={16} />
              <span>Faction:</span>
              <strong>{MOCK.players.find((p) => p.id === selectedPlayer)?.faction}</strong>
            </div>

            <div className={styles.detailRow}>
              <Heart size={16} />
              <span>Health Status:</span>
              <div className={styles.healthPips}>
                {[...Array(5)].map((_, i) => (
                  <span
                    key={i}
                    className={`${styles.pip} ${i < 4 ? styles.filled : ""}`}
                  >
                    ●
                  </span>
                ))}
              </div>
            </div>

            <div className={styles.detailRow}>
              <FlaskConical size={16} />
              <span>Morale:</span>
              <div className={styles.moralePips}>
                {[...Array(5)].map((_, i) => (
                  <span
                    key={i}
                    className={`${styles.pip} ${i < 3 ? styles.filled : ""}`}
                  >
                    ★
                  </span>
                ))}
              </div>
            </div>

            <div className={styles.detailRow}>
              <Anchor size={16} />
              <span>Available for:</span>
              <Badge variant='outline'>Quests</Badge>
              <Badge variant='outline'>Trade</Badge>
              <Badge variant='outline'>Squad</Badge>
            </div>

            <div className={styles.panelHeader}>
              <Gift size={18} />
              <span>Available Actions</span>
            </div>

            {MOCK.players
              .find((p) => p.id === selectedPlayer)
              ?.availableActions.map((action, index) => (
                <div
                  key={index}
                  className={styles.actionDetail}
                >
                  <button className={styles.actionIconButton}>
                    <action.icon size={20} />
                  </button>
                  <div className={styles.actionInfo}>
                    <span>{action.label}</span>
                    {Object.keys(action.cost).length > 0 && (
                      <Badge variant='secondary'>
                        Cost:{" "}
                        {Object.entries(action.cost)
                          .map(([key, value]) => {
                            if (key === "gold") return `${value}g`
                            if (key === "reputation") return `${value} rep`
                            return ""
                          })
                          .filter(Boolean)
                          .join(" + ")}
                      </Badge>
                    )}
                  </div>
                </div>
              ))}

            <div className={styles.panelHeader}>
              <Users size={18} />
              <span>Squad Status</span>
            </div>

            <div className={styles.squadStatus}>
              <Badge variant='outline'>Not in Squad</Badge>
              <p style={{ fontSize: "12px", color: "#a89f91" }}>
                This player is currently not part of any squad alliance.
              </p>
            </div>

            <div className={styles.panelHeader}>
              <Castle size={18} />
              <span>Faction Info</span>
            </div>

            <div className={styles.factionInfo}>
              <div className={styles.factionBadgeLarge}>
                {MOCK.players.find((p) => p.id === selectedPlayer)?.faction}
              </div>
              <p style={{ fontSize: "12px", color: "#a89f91" }}>
                A powerful faction known for their expertise in{" "}
                {MOCK.players.find((p) => p.id === selectedPlayer)?.title.toLowerCase()} arts.
              </p>
            </div>

            <div className={styles.actionButtons}>
              <Button onClick={() => handleAction(selectedPlayer, "inviteSquad")}>
                <UserPlus size={16} />
                Invite to Squad
              </Button>
              <Button
                variant='outline'
                onClick={() => handleAction(selectedPlayer, "trade")}
              >
                <Gift size={16} />
                Initiate Trade
              </Button>
            </div>
          </div>
        )}

        {selectedPlayer !== null && (
          <div className={styles.emptyState}>
            <Users size={32} />
            <span>Select a player to view details</span>
          </div>
        )}
      </div>
    </div>
  )
}
