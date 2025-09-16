import Foundation
import UIKit
import CoreHaptics

class HybridHaptic: HybridHapticSpec {
  private var engine: CHHapticEngine?

  func isAvailable() throws -> Bool {
    if #available(iOS 13.0, *) {
      return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    return false
  }

  func notify(preset: HapticPreset) throws {
    switch preset {
    case .selection:
      let g = UISelectionFeedbackGenerator()
      g.prepare()
      g.selectionChanged()
    case .impactlight:
      let g = UIImpactFeedbackGenerator(style: .light)
      g.prepare()
      g.impactOccurred()
    case .impactmedium:
      let g = UIImpactFeedbackGenerator(style: .medium)
      g.prepare()
      g.impactOccurred()
    case .impactheavy:
      let g = UIImpactFeedbackGenerator(style: .heavy)
      g.prepare()
      g.impactOccurred()
    case .impactsoft:
      if #available(iOS 13.0, *) {
        let g = UIImpactFeedbackGenerator(style: .soft)
        g.prepare()
        g.impactOccurred()
      } else {
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare()
        g.impactOccurred()
      }
    case .impactrigid:
      if #available(iOS 13.0, *) {
        let g = UIImpactFeedbackGenerator(style: .rigid)
        g.prepare()
        g.impactOccurred()
      } else {
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare()
        g.impactOccurred()
      }
    case .notificationsuccess:
      let g = UINotificationFeedbackGenerator()
      g.prepare()
      g.notificationOccurred(.success)
    case .notificationwarning:
      let g = UINotificationFeedbackGenerator()
      g.prepare()
      g.notificationOccurred(.warning)
    case .notificationerror:
      let g = UINotificationFeedbackGenerator()
      g.prepare()
      g.notificationOccurred(.error)
    }
  }

  func play(pattern: HapticPattern) throws {
    if #available(iOS 13.0, *), try (isAvailable()) {
      do {
        if engine == nil {
          engine = try CHHapticEngine()
          try engine?.start()
        }
        let events = try pattern.events.sorted { $0.time < $1.time }.map { e -> CHHapticEvent in
          let time = CHHapticTimeImmediate + Double(e.time)
          let intensity = Float(e.parameters?.intensity ?? 1.0)
          let sharpness = Float(e.parameters?.sharpness ?? 0.5)
          switch e.eventType {
          case .haptictransient:
            return CHHapticEvent(eventType: .hapticTransient, parameters: [
              CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
              CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: time, duration: 0.0)
          case .hapticcontinuous:
            let dur = max(0.001, e.eventDuration ?? 0.1)
            return CHHapticEvent(eventType: .hapticContinuous, parameters: [
              CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
              CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            ], relativeTime: time, duration: dur)
          }
        }
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine!.makePlayer(with: pattern)
        try player.start(atTime: 0)
      } catch {
        // Swallow errors to keep behavior consistent with original code,
        // but method must be `throws` to satisfy protocol.
        // You can `throw error` here if you want errors to propagate.
      }
    }
  }
}
