import { NitroModules } from 'react-native-nitro-modules'
import type { Haptic, HapticPreset, HapticPattern } from './specs/NitroHaptic.nitro'
export type { HapticPreset, HapticPattern } from './specs/NitroHaptic.nitro'
export { RNHFPresetToNitro } from './presets'

export const NitroHaptic = NitroModules.createHybridObject('Haptic') as Haptic

export const notify = (preset: HapticPreset) => NitroHaptic.notify(preset)
export const play = (pattern: HapticPattern) => NitroHaptic.play(pattern)
