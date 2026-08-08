import { doTradeOpenAction } from "@/methods/actions/trade/doTradeOpenAction"
import { useOtherPlayerId } from "@/methods/hooks/players/composite/useOtherPlayerId"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { toast } from "sonner"

export function useOpenTrade() {
  const { playerId } = usePlayerId()
  const otherPlayerId = useOtherPlayerId()

  async function openTrade() {
    try {
      const result = await doTradeOpenAction({
        playerId,
        invitedPlayerId: otherPlayerId,
      })

      if (!result.status) {
        return toast.error(result.message)
      }

      toast.success(`Trade opened with player ${otherPlayerId}!`)
    } catch (error) {
      console.error("Error opening trade:", error)
    }
  }

  return { openTrade }
}
