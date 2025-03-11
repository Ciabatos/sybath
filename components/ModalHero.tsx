"use client"

import styles from "@/components/styles/ModalHero.module.css" // Import the CSS module
import { Button } from "@heroui/button"
import { cn } from "@heroui/theme"
import type React from "react"
import { useState } from "react"

interface HeroPanelProps {
  title?: string
  content?: React.ReactNode
  buttonText?: string
}

export default function ModalHero({ title = "Hero Panel", content = "This is the hero panel content. You can customize this with any content you need.", buttonText = "Open Panel" }: HeroPanelProps) {
  const [isOpen, setIsOpen] = useState(true)

  return (
    <div className={styles.container}>
      {!isOpen && (
        <Button
          onClick={() => setIsOpen(!isOpen)}
          className={styles.button}>
          {isOpen ? "Close Panel" : buttonText}
        </Button>
      )}

      <div className={cn(styles.panel, isOpen ? styles.panelOpen : styles.panelClosed)}>
        <div className={styles.panelContent}>
          <div className={styles.panelHeader}>
            <h2 className={styles.panelTitle}>{title}</h2>
            <button
              onClick={() => setIsOpen(false)}
              className={styles.closeButton}
              aria-label="Close panel">
              <span className={styles.closeIcon}>
                <span className={cn(styles.closeIconLine, styles.closeIconLineFirst)}></span>
                <span className={cn(styles.closeIconLine, styles.closeIconLineSecond)}></span>
              </span>
            </button>
          </div>

          <div className={styles.scrollableContent}>{content}</div>
        </div>
      </div>
    </div>
  )
}
