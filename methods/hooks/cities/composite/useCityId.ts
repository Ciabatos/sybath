import { useFetchPlayerCity } from "@/methods/hooks/cities/core/useFetchPlayerCity"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"

export function useCityId() {
  const { playerId } = usePlayerId()
  const { playerCity } = useFetchPlayerCity({ playerId })

  const cityId = Object.values(playerCity)[0].cityId

  return { cityId }
}
