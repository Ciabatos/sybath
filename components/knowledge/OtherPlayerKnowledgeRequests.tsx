// GENERATED CODE - DO EDIT MANUALLY - createPanels.hbs
"use client"
import { Button } from "@/components/ui/button"
import { useOtherPlayerKnowledgeControls } from "@/methods/hooks/knowledge/composite/useOtherPlayerKnowledgeControls"
import { useOtherPlayerKnowledgeRequests } from "@/methods/hooks/knowledge/composite/useOtherPlayerKnowledgeRequests"
import { useModalTopCenter } from "@/methods/hooks/modals/useModalTopCenter"
import { X } from "lucide-react"
import styles from "./styles/OtherPlayerKnowledgeRequests.module.css"

export default function OtherPlayerKnowledgeRequests() {
  const { resetModalTopCenter } = useModalTopCenter()
  const { acceptKnowledgeRequest, declineKnowledgeRequest } = useOtherPlayerKnowledgeControls()

  function closeOtherPlayerKnowledgeRequests() {
    resetModalTopCenter()
  }

  const { otherPlayerKnowledgeRequests } = useOtherPlayerKnowledgeRequests()

  return (
    <div className={styles.overlay}>
      <div className={styles.panel}>
        <Button
          onClick={closeOtherPlayerKnowledgeRequests}
          variant='ghost'
          size='icon'
        >
          <X />
        </Button>
        {Object.values(otherPlayerKnowledgeRequests).map((request) => (
          <div key={request.otherPlayerKnowledgeRequestId}>
            <Button onClick={() => acceptKnowledgeRequest(request.otherPlayerKnowledgeRequestId)}>
              Invited to by {request.name} {request.nickname} {request.secondName}
            </Button>
            <Button
              onClick={() => declineKnowledgeRequest(request.otherPlayerKnowledgeRequestId)}
              variant='destructive'
            >
              Decline
            </Button>
          </div>
        ))}
      </div>
    </div>
  )
}
