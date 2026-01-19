import { useFetchPlayerCity } from "@/methods/hooks/cities/core/useFetchPlayerCity"
import { usePlayerId } from "@/methods/hooks/players/composite/usePlayerId"
import { playerCityAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"

export function useCityId() {
  const { playerId } = usePlayerId()

  useFetchPlayerCity({ playerId })
  const playerCity = useAtomValue(playerCityAtom)

  const cityId = Object.values(playerCity)[0].cityId

  return { cityId }
}
