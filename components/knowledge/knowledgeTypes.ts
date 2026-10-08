/**
 * Mapowanie `knowledgeTypeId` na etykiety.
 *
 * Wartości wyprowadzone z eksportowanych helperów `useOtherPlayerKnowledgeControls`
 * (inviteToKnownProfile = 1, inviteToKnownSkills = 2, ...). W projekcie nie ma
 * osobnego enuma, więc jeśli zmienisz numerację w bazie, aktualizuj tutaj.
 */
export const KNOWLEDGE_TYPE_LABELS: Record<number, string> = {
  1: "Profile",
  2: "Skills",
  3: "Abilities",
  4: "Stats",
  5: "Inventory",
  6: "Position",
}

const UNKNOWN_LABEL = "Knowledge"

export function knowledgeTypeLabel(knowledgeTypeId: number): string {
  return KNOWLEDGE_TYPE_LABELS[knowledgeTypeId] ?? UNKNOWN_LABEL
}

export const REQUESTS_HEADER = {
  title: "Knowledge Requests",
  subtitleEmpty: "No pending requests",
  subtitleOne: "1 hero is waiting on you",
  subtitleMany: (count: number) => `${count} heroes are waiting on you`,
  emptyText: "Nobody has asked you to share your knowledge.",
  accept: "Accept",
  decline: "Decline",
  /** np. "wants to share his Skills" */
  intent: (label: string) => `wants to share his ${label}`,
} as const