"use client"
import PartyInventory from "@/components/Modals/ModalLeftTop/PartyInventory"
import PlayerAbilities from "@/components/Modals/ModalLeftTop/PlayerAbilities"
import PlayerInventory from "@/components/Modals/ModalLeftTop/PlayerInventory"
import PlayerSkills from "@/components/Modals/ModalLeftTop/PlayerSkills"
import styles from "@/components/styles/ModalPlayerPanel.module.css" // Import the CSS module
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { cn } from "@/lib/utils"
import { Avatar, AvatarFallback, AvatarImage } from "@radix-ui/react-avatar"
import { useState } from "react"

export default function ModalPlayerPanel() {
  const [isOpen, setIsOpen] = useState(false)
  const [isPartyVisible, setIsPartyVisible] = useState(false)

  return (
    <div className={styles.container}>
      {!isOpen && (
        <Button
          onClick={() => setIsOpen(!isOpen)}
          className={cn(styles.button, isOpen ? styles.panelClosed : styles.button, "h-auto w-auto p-1")}
          size="icon">
          <Avatar className="h-12 w-12">
            <AvatarImage
              src="https://github.com/shadcn.png"
              alt="@shadcn"
            />
            <AvatarFallback>CN</AvatarFallback>
          </Avatar>
        </Button>
      )}

      <div className={cn(styles.panel, isOpen ? styles.panelOpen : styles.panelClosed)}>
        <div className={styles.panelContent}>
          <Button
            onClick={() => setIsOpen(false)}
            className={styles.closeButton}>
            Close Panel
          </Button>

          <div className="text-large h-20 w-20">
            <Avatar>
              <AvatarImage
                src="https://github.com/shadcn.png"
                alt="@shadcn"
              />
              <AvatarFallback>CN</AvatarFallback>
            </Avatar>
          </div>

          <div className="flex flex-1 flex-col justify-between">
            <div className={`flex min-h-0 flex-1 flex-col ${!isPartyVisible ? "h-full" : ""}`}>
              <Tabs
                defaultValue="Stats"
                className="flex w-[400px] flex-1 flex-col">
                <TabsList className="grid w-full grid-cols-5">
                  <TabsTrigger value="Stats">Stats</TabsTrigger>
                  <TabsTrigger value="Inventory">Inventory</TabsTrigger>
                  <TabsTrigger value="Skills">Skills</TabsTrigger>
                  <TabsTrigger value="Abilities">Abilities</TabsTrigger>
                  <TabsTrigger value="Knowledge">Knowledge</TabsTrigger>
                </TabsList>
                <TabsContent
                  value="Stats"
                  className="flex-1 overflow-auto">
                  Stats
                </TabsContent>
                <TabsContent
                  value="Inventory"
                  className="flex-1 overflow-auto">
                  <PlayerInventory />
                </TabsContent>
                <TabsContent
                  value="Skills"
                  className="flex-1 overflow-auto">
                  Skills slużą do pokazania jakie umiejętności posiada postać. Można je przekazywać innym postaciom ale nie są to aktywne abilities
                  <PlayerSkills />
                </TabsContent>
                <TabsContent
                  value="Abilities"
                  className="flex-1 overflow-auto">
                  Abilities służą do używania, są to aktywne umiejętności, które można używać w walce lub produkcji i innych sytuacjach, ability powstaja jeżeli masz różne kombinacje skills, stats i
                  knowledge.
                  <PlayerAbilities />
                </TabsContent>
                <TabsContent
                  value="Knowledge"
                  className="flex-1 overflow-auto">
                  Knowledge jest to wiedza danego herosa najczęsciej o innych postaciach, lokalizacjach z Mapy Świata
                </TabsContent>
              </Tabs>
            </div>

            <Button
              variant="ghost"
              size="lg"
              onClick={() => setIsPartyVisible(!isPartyVisible)}
              className="my-2 self-center">
              Party
            </Button>

            {isPartyVisible && (
              <div className="flex min-h-0 flex-1 flex-col">
                <Tabs
                  defaultValue="Units"
                  className="flex w-[400px] flex-1 flex-col">
                  <TabsList className="grid w-full grid-cols-2">
                    <TabsTrigger value="Units">Units</TabsTrigger>
                    <TabsTrigger value="Party Inventory">Party Inventory</TabsTrigger>
                  </TabsList>

                  <TabsContent
                    value="Units"
                    className="flex-1 overflow-auto">
                    Party Leader
                    <div className="text-large h-20 w-20">
                      <Avatar>
                        <AvatarImage
                          src="https://github.com/shadcn.png"
                          alt="@shadcn"
                        />
                        <AvatarFallback>CN</AvatarFallback>
                      </Avatar>
                      Units Grid
                      <Button>{"Formation >"}</Button>
                    </div>
                  </TabsContent>
                  <TabsContent
                    value="Party Inventory"
                    className="flex-1 overflow-auto">
                    <PartyInventory />
                  </TabsContent>
                </Tabs>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
