import { Avatar, AvatarImage } from "@/components/ui/avatar"
import { createImage } from "@/methods/functions/util/createImage"
import usePlayerKnownPlayers from "@/methods/hooks/knowledge/composite/usePlayerKnownPlayers"
import { MapPin, Skull } from "lucide-react"
import styles from "./styles/PlayerKnowledge.module.css"

export function PlayerKnowledge() {
  const { createPlayerPortrait } = createImage()
  const { playerKnownPlayers } = usePlayerKnownPlayers()
  const crimesKnowledge = [
    {
      icon: <Skull />,
      title: "Murder",
      description: "Murder of Serghios by Kako.",
      level: "Known" as const,
    },
    {
      icon: <Skull />,
      title: "Murder",
      description: "Murder of Pako by Kako.",
      level: "Partial" as const,
    },
  ]

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <p className={styles.headerText}>
          Knowledge represents what your hero has learned about the world, its locations, factions, and ancient lore.
        </p>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Locations</h3>
        <div className={styles.categoryItems}>
          {crimesKnowledge.map((item, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeIcon}>
                <MapPin />
              </div>
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>{item.title}</h4>
                  <span className={`${styles.knowledgeLevel} ${styles[`level${item.level}`]}`}>{item.level}</span>
                </div>
                <p className={styles.knowledgeDescription}>{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Heroes</h3>
        <div className={styles.categoryItems}>
          {Object.values(playerKnownPlayers).map((player, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>
                    {player.name
                      ? player.name + (player.nickname ? ` (${player.nickname})` : "") + " " + player.secondName
                      : player.otherPlayerId}
                  </h4>
                  <div className={styles.knowledgeIcon}>{player.x ? <MapPin /> : ""}</div>
                </div>
                <Avatar className={styles.avatar}>
                  <AvatarImage
                    src={
                      player.imagePortrait && player.imagePortrait.trim() !== ""
                        ? createPlayerPortrait(player.imagePortrait)
                        : createPlayerPortrait("masked.png")
                    }
                    alt='Hero avatar'
                    className={styles.avatarImage}
                  />
                </Avatar>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Factions</h3>
        <div className={styles.categoryItems}>
          {crimesKnowledge.map((item, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeIcon}>
                <MapPin />
              </div>
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>{item.title}</h4>
                  <span className={`${styles.knowledgeLevel} ${styles[`level${item.level}`]}`}>{item.level}</span>
                </div>
                <p className={styles.knowledgeDescription}>{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Lore</h3>
        <div className={styles.categoryItems}>
          {crimesKnowledge.map((item, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeIcon}>
                <MapPin />
              </div>
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>{item.title}</h4>
                  <span className={`${styles.knowledgeLevel} ${styles[`level${item.level}`]}`}>{item.level}</span>
                </div>
                <p className={styles.knowledgeDescription}>{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className={styles.category}>
        <h3 className={styles.categoryTitle}>Crimes</h3>
        <div className={styles.categoryItems}>
          {crimesKnowledge.map((item, index) => (
            <div
              key={index}
              className={styles.knowledgeItem}
            >
              <div className={styles.knowledgeIcon}>
                <MapPin />
              </div>
              <div className={styles.knowledgeInfo}>
                <div className={styles.knowledgeHeader}>
                  <h4 className={styles.knowledgeTitle}>{item.title}</h4>
                  <span className={`${styles.knowledgeLevel} ${styles[`level${item.level}`]}`}>{item.level}</span>
                </div>
                <p className={styles.knowledgeDescription}>{item.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
