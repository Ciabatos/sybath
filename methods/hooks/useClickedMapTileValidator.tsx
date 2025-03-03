export function useClickedMapTileValidator() {
  function checkIfMapTileContainsPlayer(x: number, y: number) {
    console.log("Checking tile:", x, y)
  }

  return { checkIfMapTileContainsPlayer }
}
