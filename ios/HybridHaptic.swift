import UIKit
import CoreHaptics
import NitroModules

class HybridHaptic: HybridHapticSpec {
  private var engine: CHHapticEngine?
  private var supportsHaptics: Bool { CHHapticEngine.capabilitiesForHardware().supportsHaptics }

  func isAvailable() -> Bool { supportsHaptics }

  func notify(preset: HapticPreset) {
    if !supportsHaptics {
      let g = UIImpactFeedbackGenerator(style: .medium)
      g.prepare()
      g.impactOccurred()
      return
    }
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

  func play(pattern: HapticPattern) -> Promise<Void> {
    if !supportsHaptics { return Promise.async { } }
    return Promise.async { [weak self] in
      guard let self else { return }
      try? self.engine?.stop(completionHandler: nil)
      self.engine = try? CHHapticEngine()
      guard let engine = self.engine else { return }
      try? engine.start()
      var events: [CHHapticEvent] = []
      for e in pattern.events.sorted(by: { $0.time < $1.time }) {
        let intensity = e.parameters?.intensity ?? 1.0
        let sharpness = e.parameters?.sharpness ?? 0.5
        let iParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity))
        let sParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness))
        switch e.eventType {
        case .haptictransient:
          let ev = CHHapticEvent(eventType: .hapticTransient, parameters: [iParam, sParam], relativeTime: e.time)
          events.append(ev)
        case .hapticcontinuous:
          let ev = CHHapticEvent(eventType: .hapticContinuous, parameters: [iParam, sParam], relativeTime: e.time, duration: e.eventDuration ?? 0.2)
          events.append(ev)
        default:
          break
        }
      }
      let pattern = try CHHapticPattern(events: events, parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    }
  }
}
