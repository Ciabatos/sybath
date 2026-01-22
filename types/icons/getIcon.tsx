import {
  Activity,
  BookOpenText,
  Brain,
  Flame,
  HandFist,
  Heart,
  Rabbit,
  Shield,
  Skull,
  Speech,
  Sword,
  Zap,
} from "lucide-react"
import { JSX } from "react"
import styles from "./icons.module.css"

const iconMap: Record<string, JSX.Element | string> = {
  Heart: <Heart className={styles.red} />,
  Zap: <Zap className={styles.yellow} />,
  Shield: <Shield className={styles.blue} />,
  Sword: <Sword className={styles.gray} />,
  Flame: <Flame className={styles.orange} />,
  HandFist: <HandFist className={styles.brown} />,
  Activity: <Activity className={styles.orange} />,
  Skull: <Skull className={styles.purple} />,
  Rabbit: <Rabbit className={styles.green} />,
  BookOpenText: <BookOpenText className={styles.orange} />,
  Brain: <Brain className={styles.purple} />,
  Speech: <Speech className={styles.blue} />,
  SwordMastery: "🗡️",
  HeavySword: "🗡",
  DualSword: "⚔️",
  HeavyArmor: "🛡️",
  Tactics: "📋",
  Endurance: "💚",
  Leadership: "👑",
  Intellect: "🧠",
  Alchemy: "⚗️",
  Blacksmithing: "🔨",
  Anvil: "⚒️",
  Stealth: "🕵️",
  Archery: "🏹",
  Magic: "🪄",
  Cooking: "🍳",
  Fishing: "🎣",
  Mining: "⚒",
  Pickaxe: "⛏️",
  Herbalism: "🌿",
  Axe: "🪓",
}

export default function getIcon(iconKey?: string) {
  if (!iconKey) return null
  return iconMap[iconKey] ?? null
}
