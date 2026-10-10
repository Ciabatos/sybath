// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TSquadInvitesRecordById,
  TSquadInvites,
  TSquadInvitesFetchParams,
} from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { squadInvitesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateSquadInvites` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const SQUADINVITES_SWR_KEY = (params: TSquadInvitesFetchParams) =>
  params.playerId != null ? `/api/squad/rpc/get-squad-invites/${params.playerId}` : null

export function useFetchSquadInvites(params: TSquadInvitesFetchParams) {
  const setSquadInvites = useSetAtom(squadInvitesAtom)

  const { data } = useSWR<TSquadInvites[]>(SQUADINVITES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const squadInvites = arrayToObjectKey(["id"], data) as TSquadInvitesRecordById
      setSquadInvites(squadInvites)
    }
  }, [data, setSquadInvites])
}

export function useSquadInvitesState() {
  return useAtomValue(squadInvitesAtom)
}
