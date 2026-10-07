/**
 * Deprecated — zastąpiony przez {@link KnowledgeRegionCard}.
 *
 * Poprzednia wersja rysowała siatkę współrzędnych z `imageFill` jako tłem.
 * Zastąpiona rozwijanymi kartami ze zwykłymi znacznikami, bo `imageFill`
 * nie jest potwierdzonym filenameem w żadnym miejscu projektu.
 *
 * Zostawione jako re-export, żeby nie zostawić wiszącego pliku odwołującego
 * się do usuniętych klas CSS (`.regionGrid`, `.tile`).
 */
export { KnowledgeRegionCard as KnowledgeRegionMap } from "@/components/knowledge/KnowledgeRegionCard"