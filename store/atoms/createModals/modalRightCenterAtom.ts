import { EPanelsRightCenter } from "@/types/enumeration/EPanelsRightCenter"
import { atom } from "jotai"

export const modalRightCenterAtom = atom<EPanelsRightCenter>(EPanelsRightCenter.Inactive)
