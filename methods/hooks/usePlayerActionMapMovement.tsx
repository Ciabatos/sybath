import { useState } from "react";

//zmiana statusu po kliknieciu button Movment
//startowa pozycja 1 klikniecie
//koncowa pozycja 2 klikniecie
//policz astar
//pokoloruj path

export const usePlayerActionMapMovement = (runAStar: (startX: number, startY: number, endX: number, endY: number, flag: number) => void) => {
  const [startPoint, setStartPoint] = useState<{ x: number; y: number } | null>(null);
  const [highlightedTile, setHighlightedTile] = useState<{ x: number; y: number } | null>(null);

  const handleClick = (x: number, y: number) => {
    if (!startPoint) {
      // First click: Set the starting point and highlight the tile
      setStartPoint({ x, y });
      setHighlightedTile({ x, y }); // Highlight the starting tile
      console.log(`Starting point set to: (${x}, ${y})`);
    } else {
      // Second click: Set the ending point, run A*, and reset the highlight
      console.log(`Ending point set to: (${x}, ${y})`);
      runAStar(startPoint.x, startPoint.y, x, y, 0); // Run A* with the selected points
      setStartPoint(null); // Reset for the next pair of clicks
      setHighlightedTile(null); // Remove the highlight
    }
  };

  // Return both the click handler and the highlighted tile coordinates
  return { handleClick, highlightedTile };
};
