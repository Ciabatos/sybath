"use client"
import styles from "@/components/styles/ModalLeftTopHandling.module.css" // Import the CSS module
import { Button } from "@/components/ui/button"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { cn } from "@/lib/utils"
import { Avatar, AvatarFallback, AvatarImage } from "@radix-ui/react-avatar"
import { useState } from "react"

export default function ModalLeftTopHandling() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className={styles.container}>
      {!isOpen && (
        <Button
          onClick={() => setIsOpen(!isOpen)}
          className={cn(styles.button, isOpen ? styles.panelClosed : styles.button)}>
          Open Panel
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
          <Tabs
            defaultValue="account"
            className="w-[400px]">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="Stats">Stats</TabsTrigger>
              <TabsTrigger value="Inventory">Inventory</TabsTrigger>
              <TabsTrigger value="Skills">Skills</TabsTrigger>
              <TabsTrigger value="Abilities">Abilities</TabsTrigger>
            </TabsList>
            <TabsContent value="Stats">Stats</TabsContent>
            <TabsContent value="Inventory">Inventory</TabsContent>
            <TabsContent value="Skills">Skills</TabsContent>
            <TabsContent value="Abilities">Abilities</TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  )
}
