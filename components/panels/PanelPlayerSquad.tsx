"use client"

import styles from "@/components/panels/styles/PanelPlayerSquad.module.css"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { useModalLeftTopBar } from "@/methods/hooks/modals/useModalLeftTopBar"
import { EPanelsLeftTopBar } from "@/types/enumeration/EPanelsLeftTopBar"
import { X } from "lucide-react"

type SquadMember = {
  id: string
  name: string
  role: string
  level: number
  health: number
  maxHealth: number
  avatarUrl?: string
}

const mockSquadMembers: SquadMember[] = [
  {
    id: "1",
    name: "Ragnar Ironside",
    role: "Warrior",
    level: 12,
    health: 85,
    maxHealth: 100,
    avatarUrl: "/warrior.jpg",
  },
  {
    id: "2",
    name: "Freya Swiftbow",
    role: "Archer",
    level: 10,
    health: 60,
    maxHealth: 75,
    avatarUrl: "/archer.png",
  },
  {
    id: "3",
    name: "Bjorn Healer",
    role: "Cleric",
    level: 11,
    health: 70,
    maxHealth: 80,
    avatarUrl: "/cleric.jpg",
  },
  {
    id: "4",
    name: "Erik Shadowblade",
    role: "Rogue",
    level: 9,
    health: 50,
    maxHealth: 65,
    avatarUrl: "/cloaked-figure.png",
  },
]

export default function PanelPlayerSquad() {
  const { setModalLeftTopBar } = useModalLeftTopBar()

  function onClose() {
    setModalLeftTopBar(EPanelsLeftTopBar.PanelPlayerPortrait)
  }
  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        {/* Header */}
        <div className={styles.header}>
          <h2 className={styles.title}>Your Squad</h2>
          <Button
            onClick={onClose}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
          >
            <X className={styles.closeIcon} />
          </Button>
        </div>

        {/* Squad Members Grid */}
        <div className={styles.content}>
          <div className={styles.squadGrid}>
            {mockSquadMembers.map((member) => (
              <div
                key={member.id}
                className={styles.memberCard}
              >
                <div className={styles.memberHeader}>
                  <Avatar className={styles.memberAvatar}>
                    <AvatarImage
                      src={member.avatarUrl || "/placeholder.svg"}
                      alt={member.name}
                    />
                    <AvatarFallback className={styles.avatarFallback}>{member.name.substring(0, 2)}</AvatarFallback>
                  </Avatar>
                  <div className={styles.memberInfo}>
                    <h3 className={styles.memberName}>{member.name}</h3>
                    <span className={styles.memberRole}>{member.role}</span>
                  </div>
                  <span className={styles.memberLevel}>Lvl {member.level}</span>
                </div>

                {/* Health Bar */}
                <div className={styles.healthSection}>
                  <div className={styles.healthLabel}>
                    <span>Health</span>
                    <span className={styles.healthValue}>
                      {member.health}/{member.maxHealth}
                    </span>
                  </div>
                  <div className={styles.healthBar}>
                    <div
                      className={styles.healthFill}
                      style={{ width: `${(member.health / member.maxHealth) * 100}%` }}
                    />
                  </div>
                </div>

                {/* Action Buttons */}
                <div className={styles.actionButtons}>
                  <Button
                    className={styles.actionButton}
                    size='sm'
                  >
                    Details
                  </Button>
                  <Button
                    className={styles.actionButton}
                    size='sm'
                    variant='outline'
                  >
                    Equipment
                  </Button>
                </div>
              </div>
            ))}
          </div>

          {/* Squad Stats */}
          <div className={styles.statsSection}>
            <h3 className={styles.statsTitle}>Squad Overview</h3>
            <div className={styles.statsGrid}>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Total Members</span>
                <span className={styles.statValue}>{mockSquadMembers.length}</span>
              </div>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Average Level</span>
                <span className={styles.statValue}>
                  {Math.round(mockSquadMembers.reduce((acc, m) => acc + m.level, 0) / mockSquadMembers.length)}
                </span>
              </div>
              <div className={styles.statItem}>
                <span className={styles.statLabel}>Total Health</span>
                <span className={styles.statValue}>
                  {mockSquadMembers.reduce((acc, m) => acc + m.health, 0)}/
                  {mockSquadMembers.reduce((acc, m) => acc + m.maxHealth, 0)}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
