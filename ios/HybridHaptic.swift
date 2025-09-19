import Foundation
import UIKit
import CoreHaptics

final class HybridHaptic: HybridHapticSpec {
  private var engine: CHHapticEngine?
  private enum EngineState { case idle, starting, running, failed }
  private var engineState: EngineState = .idle
  private var pendingBlocks: [() -> Void] = []

  private func onMain(_ block: @escaping () -> Void) {
    if Thread.isMainThread { block() } else { DispatchQueue.main.async { block() } }
  }

  private func ensureEngineReadyThen(_ block: @escaping () -> Void) {
    onMain { [weak self] in
      guard let self = self else { return }
      guard #available(iOS 13.0, *),
            CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
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
            let e = try CHHapticEngine()
            e.isAutoShutdownEnabled = true

            e.stoppedHandler = { [weak self] _ in
              self?.engineState = .idle
            }
            e.resetHandler = { [weak self] in
              self?.engineState = .idle
            }

            self.engine = e
          }

          try self.engine?.start()
          self.engineState = .running

          let toRun = self.pendingBlocks
          self.pendingBlocks.removeAll()
          toRun.forEach { $0() }

        } catch {
          self.engineState = .failed
          self.pendingBlocks.removeAll()
          NSLog("[Haptic] Engine start failed: \(error)")
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
    onMain {
      switch preset {
      case .selection:
        let g = UISelectionFeedbackGenerator()
        g.prepare(); g.selectionChanged()

      case .impactlight:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

      case .impactmedium:
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

      case .impactheavy:
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

      case .impactsoft:
        if #available(iOS 13.0, *) {
          UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } else {
          UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }

      case .impactrigid:
        if #available(iOS 13.0, *) {
          UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        } else {
          UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }

      case .notificationsuccess:
        UINotificationFeedbackGenerator().notificationOccurred(.success)

      case .notificationwarning:
        UINotificationFeedbackGenerator().notificationOccurred(.warning)

      case .notificationerror:
        UINotificationFeedbackGenerator().notificationOccurred(.error)
      }
    }
  }

  func play(pattern: HapticPattern) throws {
    ensureEngineReadyThen { [weak self] in
      guard let self = self else { return }
      guard #available(iOS 13.0, *),
            CHHapticEngine.capabilitiesForHardware().supportsHaptics,
            let engine = self.engine else {
        return
      }

      do {
        let filtered = pattern.events
          .filter { $0.time >= 0 }
          .sorted { $0.time < $1.time }

        guard !filtered.isEmpty else { return }

        var events: [CHHapticEvent] = []
        events.reserveCapacity(filtered.count)

        for e in filtered {
          let t = TimeInterval(e.time)
          let intensity = Float(max(0.0, min(1.0, e.parameters?.intensity ?? 1.0)))
          let sharpness = Float(max(0.0, min(1.0, e.parameters?.sharpness ?? 0.5)))

          switch e.eventType {
          case .haptictransient:
            events.append(
              CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                  CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                  CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: t
              )
            )

          case .hapticcontinuous:
            let dur = max(0.001, e.eventDuration ?? 0.2)
            events.append(
              CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                  CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                  CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: t,
                duration: TimeInterval(dur)
              )
            )
          }
        }

        guard !events.isEmpty else { return }

        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine.makePlayer(with: pattern)

        if self.engineState != .running {
          do {
            try engine.start()
            self.engineState = .running
          } catch {
            NSLog("[Haptic] engine.start() failed: \(error)")
            return
          }
        }
        
        try player.start(atTime: 0)
      } catch {
        NSLog("[Haptic] play() failed: \(error)")
      }
    }
  }
}
