/**
 * Statyczna konfiguracja układu ekwipunku (paper-doll).
 *
 * Sloty gearowe są opisane po `inventorySlotTypeId`, tak samo jak w logice drag & drop.
 * Ikony pochodzą z `getIcon` (klucze iconMap), a podpisy są robocze — docelowo powinny
 * przyjść z `inventory.inventory_slot_types` po lokalizacji.
 */

export type TGearSlotConfig = {
  slotTypeId: number
  icon: string
  label: string
}

export const GEAR_SLOT_TYPES = {
  necklace: 2,
  gloveLeft: 3,
  gloveRight: 4,
  chest: 5,
  belt1: 6,
  belt2: 7,
  belt3: 8,
  ringLeft: 9,
  ringRight: 10,
  boots: 11,
  weapon: 12,
  offHand: 13,
  helmet: 14,
} as const

/**
 * Kolejność komórek siatki 5 x 4. `null` oznacza pustą przestrzeń,
 * która nie jest slotem i nie reaguje na drag & drop.
 */
export const GEAR_LAYOUT: (TGearSlotConfig | null)[] = [
  null,
  { slotTypeId: GEAR_SLOT_TYPES.helmet, icon: "GiCrestedHelmet", label: "Helmet" },
  { slotTypeId: GEAR_SLOT_TYPES.necklace, icon: "GiEmeraldNecklace", label: "Necklace" },
  null,
  null,

  { slotTypeId: GEAR_SLOT_TYPES.gloveLeft, icon: "Gloves", label: "Glove L" },
  { slotTypeId: GEAR_SLOT_TYPES.weapon, icon: "GiDropWeapon", label: "Main Hand" },
  { slotTypeId: GEAR_SLOT_TYPES.gloveRight, icon: "Gloves", label: "Glove R" },
  { slotTypeId: GEAR_SLOT_TYPES.chest, icon: "GiChestArmor", label: "Chest" },
  { slotTypeId: GEAR_SLOT_TYPES.offHand, icon: "HeavyShield", label: "Off Hand" },

  { slotTypeId: GEAR_SLOT_TYPES.ringLeft, icon: "GiBigDiamondRing", label: "Ring L" },
  { slotTypeId: GEAR_SLOT_TYPES.belt1, icon: "GiBelt", label: "Belt I" },
  { slotTypeId: GEAR_SLOT_TYPES.belt2, icon: "GiBelt", label: "Belt II" },
  { slotTypeId: GEAR_SLOT_TYPES.belt3, icon: "GiBelt", label: "Belt III" },
  { slotTypeId: GEAR_SLOT_TYPES.ringRight, icon: "GiBigDiamondRing", label: "Ring R" },

  { slotTypeId: GEAR_SLOT_TYPES.boots, icon: "GiSteeltoeBoots", label: "Boots" },
  null,
  null,
  null,
  null,
]

export const GEAR_SECTION = {
  title: "Equipment",
  hint: "Drag an item onto its slot to equip it",
  slotsTotal: GEAR_LAYOUT.filter((cell) => cell !== null).length,
} as const

export const BAG_SECTION = {
  title: "Backpack",
  hint: "Drag items between slots to rearrange",
  emptyHint: "Your backpack is empty. Loot something to fill it up.",
} as const