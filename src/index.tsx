import { NitroModules } from 'react-native-nitro-modules';
import type { NitroHaptic } from './NitroHaptic.nitro';

const NitroHapticHybridObject =
  NitroModules.createHybridObject<NitroHaptic>('NitroHaptic');

export function multiply(a: number, b: number): number {
  return NitroHapticHybridObject.multiply(a, b);
}
