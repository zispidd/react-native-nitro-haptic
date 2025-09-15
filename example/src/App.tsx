import { useCallback, useMemo } from 'react'
import { SafeAreaView, View, Text, Pressable, FlatList, StyleSheet, StatusBar } from 'react-native'
import { notify, play } from 'react-native-nitro-haptic'
import type { HapticPreset, HapticPattern } from 'react-native-nitro-haptic'

const PRESETS: HapticPreset[] = [
  'selection',
  'impactLight',
  'impactMedium',
  'impactHeavy',
  'impactSoft',
  'impactRigid',
  'notificationSuccess',
  'notificationWarning',
  'notificationError'
]

const longTransition: HapticPattern = {
  events: [
    {
      eventType: 'hapticContinuous',
      time: 0,
      eventDuration: 0.4,
      parameters: { intensity: 0.3, sharpness: 0.1 }
    },
    {
      eventType: 'hapticTransient',
      time: 0.425,
      parameters: { intensity: 0.3, sharpness: 0.3 }
    },
    {
      eventType: 'hapticTransient',
      time: 0.5,
      parameters: { intensity: 0.5, sharpness: 0.25 }
    },
    {
      eventType: 'hapticTransient',
      time: 0.55,
      parameters: { intensity: 0.8, sharpness: 0.15 }
    },
    {
      eventType: 'hapticContinuous',
      time: 0.6,
      eventDuration: 0.55,
      parameters: { intensity: 0.2, sharpness: 0.2 }
    }
  ]
}

const burst = {
  events: Array.from({ length: 6 }).map((_, i) => ({
    eventType: 'hapticTransient' as const,
    time: i * 0.06,
    parameters: { intensity: 0.6 + i * 0.06, sharpness: 0.4 + i * 0.05 }
  }))
}

const heartbeat: HapticPattern = {
  events: [
    { eventType: 'hapticTransient', time: 0, parameters: { intensity: 0.8, sharpness: 0.2 } },
    { eventType: 'hapticTransient', time: 0.2, parameters: { intensity: 1, sharpness: 0.3 } }
  ]
}

const crescendo: HapticPattern = {
  events: Array.from({ length: 8 }).map((_, i) => ({
    eventType: 'hapticTransient' as const,
    time: i * 0.06,
    parameters: { intensity: Math.min(0.2 + i * 0.1, 1), sharpness: 0.3 + i * 0.05 }
  }))
}

const drumroll: HapticPattern = {
  events: [
    ...Array.from({ length: 12 }).map((_, i) => ({
      eventType: 'hapticTransient' as const,
      time: i * 0.04,
      parameters: { intensity: 0.25, sharpness: 0.4 }
    })),
    { eventType: 'hapticTransient', time: 12 * 0.04 + 0.06, parameters: { intensity: 0.9, sharpness: 0.6 } }
  ]
}

const ripple: HapticPattern = {
  events: [
    { eventType: 'hapticContinuous', time: 0, eventDuration: 0.2, parameters: { intensity: 0.5, sharpness: 0.2 } },
    { eventType: 'hapticContinuous', time: 0.25, eventDuration: 0.2, parameters: { intensity: 0.35, sharpness: 0.3 } },
    { eventType: 'hapticContinuous', time: 0.5, eventDuration: 0.2, parameters: { intensity: 0.2, sharpness: 0.4 } }
  ]
}

const bounce: HapticPattern = {
  events: [
    { eventType: 'hapticTransient', time: 0, parameters: { intensity: 0.95, sharpness: 0.6 } },
    { eventType: 'hapticTransient', time: 0.12, parameters: { intensity: 0.6, sharpness: 0.4 } },
    { eventType: 'hapticTransient', time: 0.24, parameters: { intensity: 0.35, sharpness: 0.25 } }
  ]
}

const swirl: HapticPattern = {
  events: [
    { eventType: 'hapticContinuous', time: 0, eventDuration: 0.5, parameters: { intensity: 0.25, sharpness: 0.2 } },
    { eventType: 'hapticContinuous', time: 0.52, eventDuration: 0.48, parameters: { intensity: 0.25, sharpness: 0.8 } }
  ]
}

const sparkle: HapticPattern = {
  events: [
    { eventType: 'hapticTransient', time: 0, parameters: { intensity: 0.5, sharpness: 0.9 } },
    { eventType: 'hapticTransient', time: 0.07, parameters: { intensity: 0.6, sharpness: 0.9 } },
    { eventType: 'hapticTransient', time: 0.14, parameters: { intensity: 0.45, sharpness: 0.9 } },
    { eventType: 'hapticTransient', time: 0.24, parameters: { intensity: 0.65, sharpness: 0.9 } },
    { eventType: 'hapticTransient', time: 0.36, parameters: { intensity: 0.5, sharpness: 0.9 } },
    { eventType: 'hapticTransient', time: 0.48, parameters: { intensity: 0.7, sharpness: 0.9 } },
    { eventType: 'hapticTransient', time: 0.62, parameters: { intensity: 0.55, sharpness: 0.9 } }
  ]
}

export default function App() {
  const onPressPreset = useCallback((p: HapticPreset) => {
    notify(p)
  }, [])

  const sections = useMemo(
    () => [
      { key: 'presets', title: 'Presets', data: PRESETS.map(p => ({ label: p, action: () => onPressPreset(p) })) },
      { key: 'patterns', title: 'Patterns', data: [
        { label: 'Long transition', action: () => play(longTransition) },
        { label: 'Burst', action: () => play(burst) },
        { label: 'Heartbeat', action: () => play(heartbeat) },
        { label: 'Crescendo', action: () => play(crescendo) },
        { label: 'Drumroll', action: () => play(drumroll) },
        { label: 'Ripple', action: () => play(ripple) },
        { label: 'Bounce', action: () => play(bounce) },
        { label: 'Swirl', action: () => play(swirl) },
        { label: 'Sparkle', action: () => play(sparkle) }
      ] }
    ],
    [onPressPreset]
  )

  return (
    <SafeAreaView style={styles.safe}>
      <StatusBar barStyle="dark-content" />
      <View style={styles.header}>
        <Text style={styles.title}>Nitro Haptic</Text>
      </View>
      <FlatList
        data={sections}
        keyExtractor={s => s.key}
        renderItem={({ item }) => (
          <View style={styles.section}>
            <Text style={styles.sectionTitle}>{item.title}</Text>
            <View style={styles.grid}>
              {item.data.map(row => (
                <Pressable key={row.label} onPress={row.action} style={({ pressed }) => [styles.button, pressed && styles.buttonPressed]}>
                  <Text style={styles.buttonText}>{row.label}</Text>
                </Pressable>
              ))}
            </View>
          </View>
        )}
        contentContainerStyle={styles.content}
      />
    </SafeAreaView>
  )
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: '#fff' },
  header: { paddingHorizontal: 20, paddingTop: 12, paddingBottom: 4, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' },
  title: { fontSize: 22, fontWeight: '700' },
  badge: { paddingHorizontal: 10, paddingVertical: 6, borderRadius: 999 },
  badgeText: { color: '#fff', fontWeight: '600' },
  content: { padding: 16, paddingTop: 8 },
  section: { marginBottom: 20 },
  sectionTitle: { fontSize: 16, fontWeight: '700', marginBottom: 8 },
  grid: { flexDirection: 'row', flexWrap: 'wrap', gap: 10 },
  button: { backgroundColor: '#0a84ff', paddingHorizontal: 14, paddingVertical: 12, borderRadius: 12 },
  buttonPressed: { opacity: 0.7 },
  buttonText: { color: '#fff', fontWeight: '600' }
})
