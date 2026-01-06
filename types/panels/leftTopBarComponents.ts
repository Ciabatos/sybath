import PanelPlayerPanel from "@/components/panels/PanelPlayerPanel"
import { EPanels } from "@/types/enumeration/EPanels"

export const panelComponentMap: Record<EPanels, React.ComponentType<any> | null> = {
  [EPanels.Inactive]: null,
  //   [EPanels.PanelActionAbility]: PanelActionAbility,
  //   [EPanels.PanelActionGuardArea]: PanelActionGuardArea,
  //   [EPanels.PanelActionMovement]: PanelActionMovement,
  //   [EPanels.PanelPlayerInventory]: PanelPlayerInventory,
  //   [EPanels.PanelBackToMap]: PanelBackToMap,
  //   [EPanels.PanelBuilding]: PanelBuilding,
  //   [EPanels.PanelCityActionBar]: PanelCityActionBar,
  //   [EPanels.PanelDistrict]: PanelDistrict,
  //   [EPanels.PanelEmptyTilePanel]: PanelEmptyTilePanel,
  //   [EPanels.PanelPartyInventory]: PanelPartyInventory,
  //   [EPanels.PanelPlayerAbilities]: PanelPlayerAbilities,
  //   [EPanels.PanelPlayerActionBar]: PanelPlayerActionBar,
  [EPanels.PanelPlayerPanel]: PanelPlayerPanel,
  //   [EPanels.PanelPlayerSkills]: PanelPlayerSkills,
}
