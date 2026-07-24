import { EPanelsBottomCenter } from "@/types/enumeration/EPanelsBottomCenter"
import { atom } from "jotai"

export const modalBottomCenterAtom = atom<EPanelsBottomCenter>(EPanelsBottomCenter.Inactive)
