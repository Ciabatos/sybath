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
  const { acceptKnowledgeRequest } = useOtherPlayerKnowledgeControls()

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
          <Button
            key={request.otherPlayerKnowledgeRequestId}
            onClick={() => acceptKnowledgeRequest(request.otherPlayerKnowledgeRequestId)}
          >
            Invited to by {request.name} {request.nickname} {request.secondName}
          </Button>
        ))}
      </div>
    </div>
  )
}
