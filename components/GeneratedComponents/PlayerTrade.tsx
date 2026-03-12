/**
 * Player Trade Interface Component
 *
 * A medieval-style trading panel for player-to-player item exchange
 * Inspired by Crusader Kings grand strategy game UI
 */

import { AlertTriangle, CheckCircle2, Coins, Crown, Scroll, Shield, User, X } from "lucide-react"
import React, { useState } from "react"
import styles from "./styles/PlayerTrade.module.css"

// Mock data for demonstration
const MOCK_OFFER_ITEMS = [
  { id: 1, name: "Iron Sword", type: "weapon", value: 50, icon: Shield },
  { id: 2, name: "Gold Coins", type: "currency", value: 100, icon: Coins },
]

const MOCK_ACCEPT_ITEMS = [
  { id: 3, name: "Leather Armor", type: "armor", value: 75, icon: Shield },
  { id: 4, name: "Ancient Scroll", type: "artifact", value: 200, icon: Scroll },
]

interface Item {
  id: number
  name: string
  type: string
  value: number
  icon: React.ElementType
}

interface PlayerTradeProps {
  offererName?: string
  acceptorName?: string
  onClose?: () => void
}

export default function PlayerTrade({
  offererName = "Lord Blackwood",
  acceptorName = "Lady Silverhand",
  onClose,
}: PlayerTradeProps) {
  const [offerItems, setOfferItems] = useState<Item[]>(MOCK_OFFER_ITEMS)
  const [acceptItems, setAcceptItems] = useState<Item[]>(MOCK_ACCEPT_ITEMS)
  const [isConfirming, setIsConfirming] = useState(false)

  // Add item to offer list
  const handleAddToOffer = (item: Item) => {
    if (offerItems.length < 5) {
      setOfferItems([...offerItems, { ...item, id: Date.now() }])
    }
  }

  // Remove item from offer list
  const handleRemoveFromOffer = (itemId: number) => {
    setOfferItems(offerItems.filter((item) => item.id !== itemId))
  }

  // Add item to accept list
  const handleAddToAccept = (item: Item) => {
    if (acceptItems.length < 5) {
      setAcceptItems([...acceptItems, { ...item, id: Date.now() }])
    }
  }

  // Remove item from accept list
  const handleRemoveFromAccept = (itemId: number) => {
    setAcceptItems(acceptItems.filter((item) => item.id !== itemId))
  }

  // Calculate total value
  const calculateTotalValue = (items: Item[]) => {
    return items.reduce((sum, item) => sum + item.value, 0)
  }

  const offerTotal = calculateTotalValue(offerItems)
  const acceptTotal = calculateTotalValue(acceptItems)

  // Handle trade confirmation
  const handleConfirmTrade = () => {
    if (offerTotal !== acceptTotal) {
      alert("Trade values must be equal!")
      return
    }

    setIsConfirming(true)
    setTimeout(() => {
      setIsConfirming(false)
      onClose?.()
    }, 1500)
  }

  // Get item type color class
  const getTypeColor = (type: string) => {
    switch (type) {
      case "weapon":
        return styles.typeWeapon
      case "armor":
        return styles.typeArmor
      case "currency":
        return styles.typeCurrency
      case "artifact":
        return styles.typeArtifact
      default:
        return styles.typeGeneric
    }
  }

  return (
    <div className={styles.container}>
      {/* Trade Panel Header */}
      <div className={styles.headerPanel}>
        <div className={styles.titleRow}>
          <Scroll
            className={styles.icon}
            size={24}
          />
          <h2 className={styles.title}>Merchant's Exchange</h2>
        </div>

        {/* Player Names */}
        <div className={styles.playerNames}>
          <div className={`${styles.playerBox} ${styles.offerer}`}>
            <User size={18} />
            <span>{offererName}</span>
          </div>
          <div className={styles.arrow}>↔</div>
          <div className={`${styles.playerBox} ${styles.acceptor}`}>
            <Crown size={18} />
            <span>{acceptorName}</span>
          </div>
        </div>

        {/* Trade Status */}
        <div className={styles.statusRow}>
          {offerTotal === acceptTotal ? (
            <span className={styles.balanceMatch}>✓ Values Balanced</span>
          ) : (
            <span className={styles.balanceMismatch}>✗ Value Mismatch</span>
          )}
        </div>
      </div>

      {/* Trade Items Section */}
      <div className={styles.itemsSection}>
        {/* Offer Panel */}
        <div className={`${styles.tradePanel} ${styles.offerPanel}`}>
          <div className={styles.panelHeader}>
            <Shield size={20} />
            <h3>Items to Offer</h3>
          </div>

          {offerItems.length === 0 ? (
            <div className={styles.emptyState}>No items selected</div>
          ) : (
            <ul className={styles.itemList}>
              {offerItems.map((item) => (
                <li
                  key={item.id}
                  className={`${styles.itemRow} ${getTypeColor(item.type)}`}
                >
                  <span className={styles.itemName}>{item.name}</span>
                  <span className={styles.itemValue}>{item.value} gold</span>
                  <button
                    className={styles.removeBtn}
                    onClick={() => handleRemoveFromOffer(item.id)}
                  >
                    <X size={14} />
                  </button>
                </li>
              ))}
            </ul>
          )}

          {/* Add Items Controls */}
          <div className={styles.addControls}>
            <span>Add:</span>
            {MOCK_OFFER_ITEMS.map((item) => (
              <button
                key={item.id}
                className={`${styles.addItemBtn} ${getTypeColor(item.type)}`}
                onClick={() => handleAddToOffer(item)}
                disabled={offerItems.length >= 5}
              >
                + {item.name}
              </button>
            ))}
          </div>

          <div className={styles.panelTotal}>
            Total: <strong>{offerTotal} gold</strong>
          </div>
        </div>

        {/* Accept Panel */}
        <div className={`${styles.tradePanel} ${styles.acceptPanel}`}>
          <div className={styles.panelHeader}>
            <Shield size={20} />
            <h3>Items to Receive</h3>
          </div>

          {acceptItems.length === 0 ? (
            <div className={styles.emptyState}>No items selected</div>
          ) : (
            <ul className={styles.itemList}>
              {acceptItems.map((item) => (
                <li
                  key={item.id}
                  className={`${styles.itemRow} ${getTypeColor(item.type)}`}
                >
                  <span className={styles.itemName}>{item.name}</span>
                  <span className={styles.itemValue}>{item.value} gold</span>
                  <button
                    className={styles.removeBtn}
                    onClick={() => handleRemoveFromAccept(item.id)}
                  >
                    <X size={14} />
                  </button>
                </li>
              ))}
            </ul>
          )}

          {/* Add Items Controls */}
          <div className={styles.addControls}>
            <span>Add:</span>
            {MOCK_ACCEPT_ITEMS.map((item) => (
              <button
                key={item.id}
                className={`${styles.addItemBtn} ${getTypeColor(item.type)}`}
                onClick={() => handleAddToAccept(item)}
                disabled={acceptItems.length >= 5}
              >
                + {item.name}
              </button>
            ))}
          </div>

          <div className={styles.panelTotal}>
            Total: <strong>{acceptTotal} gold</strong>
          </div>
        </div>
      </div>

      {/* Trade Actions */}
      <div className={styles.actionsPanel}>
        {isConfirming ? (
          <button className={`${styles.confirmBtn} ${styles.confirming}`}>
            <CheckCircle2 size={20} />
            Processing...
          </button>
        ) : (
          <>
            <button
              className={styles.cancelBtn}
              onClick={() => onClose?.()}
            >
              Cancel Trade
            </button>
            <button
              className={`${styles.confirmBtn} ${offerTotal === acceptTotal ? styles.enabled : styles.disabled}`}
              onClick={handleConfirmTrade}
              disabled={offerTotal !== acceptTotal || offerItems.length === 0 || acceptItems.length === 0}
            >
              Confirm Exchange
            </button>
          </>
        )}
      </div>

      {/* Warning Alert */}
      {offerTotal !== acceptTotal && (
        <div className={styles.warningAlert}>
          <AlertTriangle size={16} />
          <span>Trade values must be equal before confirmation</span>
        </div>
      )}
    </div>
  )
}
