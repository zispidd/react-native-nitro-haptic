import type { HapticPreset } from './specs/NitroHaptic.nitro'

export const RNHFPresetToNitro: Record<string, HapticPreset> = {
  selection: 'selection',
  impactLight: 'impactLight',
  impactMedium: 'impactMedium',
  impactHeavy: 'impactHeavy',
  rigid: 'impactRigid',
  soft: 'impactSoft',
  notificationSuccess: 'notificationSuccess',
  notificationWarning: 'notificationWarning',
  notificationError: 'notificationError'
}
