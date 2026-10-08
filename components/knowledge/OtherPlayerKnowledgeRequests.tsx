// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"

import { REQUESTS_HEADER, knowledgeTypeLabel } from "@/components/knowledge/knowledgeTypes"
import PlayerPortrait from "@/components/players/PlayerPortrait"
import { TOtherPlayerKnowledgeRequests } from "@/db/postgresMainDatabase/schemas/knowledge/otherPlayerKnowledgeRequests"
import { Button } from "@/components/ui/button"
import { useOtherPlayerKnowledgeControls } from "@/methods/hooks/knowledge/composite/useOtherPlayerKnowledgeControls"
import { useOtherPlayerKnowledgeRequests } from "@/methods/hooks/knowledge/composite/useOtherPlayerKnowledgeRequests"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { ScrollText, X } from "lucide-react"
import { useState } from "react"
import styles from "./styles/OtherPlayerKnowledgeRequests.module.css"

export default function OtherPlayerKnowledgeRequests() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { acceptKnowledgeRequest, declineKnowledgeRequest } = useOtherPlayerKnowledgeControls()

  const { otherPlayerKnowledgeRequests } = useOtherPlayerKnowledgeRequests()

  // Id zapytania, którego akcja jest w locie — blokuje podwójne kliknięcia.
  const [pendingId, setPendingId] = useState<number | null>(null)

  function closeOtherPlayerKnowledgeRequests() {
    resetModalTopCenter()
  }

  async function handleAccept(inviteId: number) {
    setPendingId(inviteId)
    await acceptKnowledgeRequest(inviteId)
    setPendingId(null)
  }

  async function handleDecline(inviteId: number) {
    setPendingId(inviteId)
    await declineKnowledgeRequest(inviteId)
    setPendingId(null)
  }

  const requests = Object.values(otherPlayerKnowledgeRequests)

  const subtitle =
    requests.length === 0
      ? REQUESTS_HEADER.subtitleEmpty
      : requests.length === 1
        ? REQUESTS_HEADER.subtitleOne
        : REQUESTS_HEADER.subtitleMany(requests.length)

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <header className={styles.header}>
          <span className={styles.headerEmblem}>
            <ScrollText className={styles.headerEmblemIcon} />
          </span>

          <div className={styles.headerInfo}>
            <h2 className={styles.title}>{REQUESTS_HEADER.title}</h2>
            <p className={styles.subtitle}>{subtitle}</p>
          </div>

          <Button
            onClick={closeOtherPlayerKnowledgeRequests}
            variant='ghost'
            size='icon'
            className={styles.closeButton}
            aria-label='Close'
          >
            <X className={styles.closeIcon} />
          </Button>
        </header>

        {requests.length === 0 ? (
          <div className={styles.empty}>
            <ScrollText className={styles.emptyIcon} />
            <p className={styles.emptyText}>{REQUESTS_HEADER.emptyText}</p>
          </div>
        ) : (
          <ul className={styles.list}>
            {requests.map((request: TOtherPlayerKnowledgeRequests) => {
              const inviteId = request.otherPlayerKnowledgeRequestId
              const isPending = pendingId === inviteId

              const fullName = [request.name, request.secondName].filter(Boolean).join(" ")
              const displayName = fullName || request.otherPlayerId

              return (
                <li key={inviteId}>
                  <div className={styles.row}>
                    <span className={styles.portrait}>
                      <PlayerPortrait imagePortrait={request.imagePortrait || null} />
                    </span>

                    <span className={styles.rowInfo}>
                      <span className={styles.rowName}>{displayName}</span>
                      <span className={styles.rowIntent}>
                        {REQUESTS_HEADER.intent(knowledgeTypeLabel(request.knowledgeTypeId))}
                      </span>
                    </span>

                    <span className={styles.rowActions}>
                      <Button
                        onClick={() => handleAccept(inviteId)}
                        disabled={isPending}
                        className={styles.acceptButton}
                      >
                        {REQUESTS_HEADER.accept}
                      </Button>
                      <Button
                        onClick={() => handleDecline(inviteId)}
                        disabled={isPending}
                        variant='destructive'
                        className={styles.declineButton}
                      >
                        {REQUESTS_HEADER.decline}
                      </Button>
                    </span>
                  </div>
                </li>
              )
            })}
          </ul>
        )}
      </div>
    </div>
  )
}