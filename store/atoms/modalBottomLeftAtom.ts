import { EPanelsBottomLeft } from "@/types/enumeration/EPanelsBottomLeft"
import { atom } from "jotai"

export const modalBottomLeftAtom = atom<EPanelsBottomLeft>(EPanelsBottomLeft.Inactive)
