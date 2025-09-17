import Foundation
import UIKit
import CoreHaptics

class HybridHaptic: HybridHapticSpec {
  private var engine: CHHapticEngine?
  private enum EngineState { case idle, starting, running, failed }
  private var engineState: EngineState = .idle
  private var pendingBlocks: [() -> Void] = []

  private func runNextMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
      DispatchQueue.main.async { block() }
    } else {
      DispatchQueue.main.async { block() }
    }
  }

  private func ensureEngineReadyThen(_ block: @escaping () -> Void) {
    runNextMain { [weak self] in
      guard let self = self else { return }
      guard #available(iOS 13.0, *) else { block(); return }

      if !CHHapticEngine.capabilitiesForHardware().supportsHaptics {
        block()
        return
      }

      switch self.engineState {
      case .running:
        block()
      case .starting:
        self.pendingBlocks.append(block)
      case .idle, .failed:
        self.pendingBlocks.append(block)
        self.engineState = .starting
        do {
          if self.engine == nil {
            self.engine = try CHHapticEngine()
            self.engine?.isAutoShutdownEnabled = true
            self.engine?.stoppedHandler = { [weak self] reason in
              self?.engineState = .idle
            }
            self.engine?.resetHandler = { [weak self] in
              self?.engineState = .idle
            }
          }
          try self.engine?.start()
          self.engineState = .running
          let toRun = self.pendingBlocks
          self.pendingBlocks.removeAll()
          toRun.forEach { $0() }
        } catch {
          self.engineState = .failed
          self.pendingBlocks.removeAll()
        }
      }
    }
  }

  func isAvailable() throws -> Bool {
    if #available(iOS 13.0, *) {
      return CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    return false
  }

  func notify(preset: HapticPreset) throws {
    runNextMain {
      switch preset {
      case .selection:
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()
      case .impactlight:
        let g = UIImpactFeedbackGenerator(style: .light)
        g.prepare(); g.impactOccurred()
      case .impactmedium:
        let g = UIImpactFeedbackGenerator(style: .medium)
        g.prepare(); g.impactOccurred()
      case .impactheavy:
        let g = UIImpactFeedbackGenerator(style: .heavy)
        g.prepare(); g.impactOccurred()
      case .impactsoft:
        if #available(iOS 13.0, *) {
          let g = UIImpactFeedbackGenerator(style: .soft)
          g.prepare(); g.impactOccurred()
        } else {
          let g = UIImpactFeedbackGenerator(style: .light)
          g.prepare(); g.impactOccurred()
        }
      case .impactrigid:
        if #available(iOS 13.0, *) {
          let g = UIImpactFeedbackGenerator(style: .rigid)
          g.prepare(); g.impactOccurred()
        } else {
          let g = UIImpactFeedbackGenerator(style: .heavy)
          g.prepare(); g.impactOccurred()
        }
      case .notificationsuccess:
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.success)
      case .notificationwarning:
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.warning)
      case .notificationerror:
        let g = UINotificationFeedbackGenerator()
        g.prepare(); g.notificationOccurred(.error)
      }
    }
  }

  func play(pattern: HapticPattern) throws {
    ensureEngineReadyThen { [weak self] in
      guard let self = self else { return }
      guard #available(iOS 13.0, *) else { return }

      do {
        let events = try pattern.events
          .sorted { $0.time < $1.time }
          .map { e -> CHHapticEvent in
            let time = CHHapticTimeImmediate + Double(e.time)
            let intensity = Float(e.parameters?.intensity ?? 1.0)
            let sharpness = Float(e.parameters?.sharpness ?? 0.5)

            switch e.eventType {
            case .haptictransient:
              return CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                  CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                  CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: time
              )
            case .hapticcontinuous:
              let dur = max(0.001, e.eventDuration ?? 0.1)
              return CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                  CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                  CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: time,
                duration: dur
              )
            }
          }

        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try self.engine!.makePlayer(with: pattern)
        try player.start(atTime: 0)
      } catch {

      }
    }
  }
}
