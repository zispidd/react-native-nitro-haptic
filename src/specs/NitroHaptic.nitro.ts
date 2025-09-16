import type { HybridObject } from 'react-native-nitro-modules'

export type HapticPreset =
  | 'selection'
  | 'impactLight'
  | 'impactMedium'
  | 'impactHeavy'
  | 'impactSoft'
  | 'impactRigid'
  | 'notificationSuccess'
  | 'notificationWarning'
  | 'notificationError'

export type HapticEventType = 'hapticTransient' | 'hapticContinuous'

export interface HapticParameters {
  intensity?: number
  sharpness?: number
}

export interface HapticEvent {
  eventType: HapticEventType
  time: number
  eventDuration?: number
  parameters?: HapticParameters
}

export interface HapticPattern {
  events: HapticEvent[]
}

export interface Haptic extends HybridObject<{ ios: 'swift', android: 'kotlin' }> {
  isAvailable(): boolean
  notify(preset: HapticPreset): void
  play(pattern: HapticPattern): void
}
