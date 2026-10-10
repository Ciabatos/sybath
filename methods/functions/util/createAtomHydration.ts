/* eslint-disable @typescript-eslint/no-explicit-any */
import * as Atoms from "@/store/atoms" // import wszystkich atomów
import { WritableAtom } from "jotai"

export type TAtomName = keyof typeof Atoms

type TServerEntity<TData = unknown> = {
  byKey: TData
  atomName: TAtomName
}

type TAtomValue = WritableAtom<any, [any], void>

export function createAtomHydration(...entities: TServerEntity[]): [TAtomValue, unknown][] {
  const atomValues: [TAtomValue, unknown][] = []
  const registry = Atoms as Record<TAtomName, TAtomValue>

  for (const entity of entities) {
    const atom = registry[entity.atomName]

    if (atom) {
      atomValues.push([atom, entity.byKey])
    }
  }

  return atomValues
}
