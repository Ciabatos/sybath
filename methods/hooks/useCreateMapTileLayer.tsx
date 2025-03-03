// atoms/highlightedTileAtom.ts
import { atom, useAtom } from "jotai";

export type HighlightedTile = {
  x: number;
  y: number;
  color: string;
} | null;

export const highlightedTileAtom = atom<HighlightedTile>(null);

// Utility function to set the highlighted tile
export const useSetHighlightedTile = () => {
  const [, setHighlightedTile] = useAtom(highlightedTileAtom);
  return (x: number, y: number, color: string) => {
    setHighlightedTile({ x, y, color });
  };
};

// Utility function to clear the highlighted tile
export const useClearHighlightedTile = () => {
  const [, setHighlightedTile] = useAtom(highlightedTileAtom);
  return () => {
    setHighlightedTile(null);
  };
};




export const isTileHighlightedAtom = (x: number, y: number) =>
  atom((get) => {
    const highlightedTile = get(highlightedTileAtom);
    return highlightedTile?.x === x && highlightedTile?.y === y;
  });

  // Check if the current tile is highlighted
  const isHighlighted = useAtomValue(isTileHighlightedAtom(tile.x, tile.y));
