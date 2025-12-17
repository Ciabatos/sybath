"use client"

import { Atom } from "jotai"
import { useHydrateAtoms } from "jotai/utils"
import { ReactNode } from "react"

type HydrateTuple<T> = readonly [Atom<T>, T]

interface Props {
  values: HydrateTuple<any>[]
  children: ReactNode
}

export function JotaiHydrationProvider({ values, children }: Props) {
  useHydrateAtoms(values)
  return <>{children}</>
}
