"use client"
import usePlayersOnTheSameTile from "@/methods/hooks/world/composite/usePlayersOnTheSameTile"

export default function PlayersOnTheSameTile() {
  const { playersOnTheSameTile } = usePlayersOnTheSameTile()
  console.log(playersOnTheSameTile)

  if (!playersOnTheSameTile) return null
  return (
    <>
      {Object.entries(playersOnTheSameTile).map(([key, otherPlayer]) => (
        <div key={key}>
          <div>{otherPlayer.name}</div>
          <div>{otherPlayer.secondName}</div>
          <div>{otherPlayer.nickname}</div>
          <div>{otherPlayer.imageMap}</div>
          <div>{otherPlayer.imagePortrait}</div>
        </div>
      ))}
    </>
  )
}
