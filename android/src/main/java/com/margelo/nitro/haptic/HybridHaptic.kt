package com.margelo.nitro.haptic

import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.core.Promise

@DoNotStrip
class HybridHaptic : HybridHapticSpec() {
  private val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= 31) {
    val vm = NitroHapticPackage.appContext.getSystemService(VibratorManager::class.java)
    vm.defaultVibrator
  } else {
    @Suppress("DEPRECATION")
    NitroHapticPackage.appContext.getSystemService(android.content.Context.VIBRATOR_SERVICE) as Vibrator
  }

  override fun isAvailable(): Boolean = vibrator.hasVibrator()

  override fun notify(preset: HapticPreset) {
    if (!vibrator.hasVibrator()) return
    when (preset) {
      HapticPreset.SELECTION -> wave(longArrayOf(16), intArrayOf(140))
      HapticPreset.IMPACTSOFT -> wave(longArrayOf(12), intArrayOf(90))
      HapticPreset.IMPACTLIGHT -> wave(longArrayOf(18), intArrayOf(160))
      HapticPreset.IMPACTMEDIUM -> wave(longArrayOf(22), intArrayOf(200))
      HapticPreset.IMPACTHEAVY -> wave(longArrayOf(26), intArrayOf(255))
      HapticPreset.IMPACTRIGID -> wave(longArrayOf(10), intArrayOf(220))
      HapticPreset.NOTIFICATIONSUCCESS -> wave(longArrayOf(14, 30, 18), intArrayOf(170, 0, 220))
      HapticPreset.NOTIFICATIONWARNING -> wave(longArrayOf(24), intArrayOf(200))
      HapticPreset.NOTIFICATIONERROR -> wave(longArrayOf(16, 40, 24), intArrayOf(200, 0, 255))
    }
  }

  override fun play(pattern: HapticPattern): Promise<Unit> = Promise.async {
    if (!vibrator.hasVibrator()) return@async Unit
    val timings = mutableListOf<Long>()
    val amplitudes = mutableListOf<Int>()
    var t = 0L
    val events = pattern.events.sortedBy { it.time }
    for (e in events) {
      val at = (e.time * 1000.0).toLong()
      val gap = (at - t).coerceAtLeast(0L)
      if (gap > 0L) {
        timings.add(gap)
        amplitudes.add(0)
        t += gap
      }
      val intensity = ((e.parameters?.intensity ?: 1.0).coerceIn(0.0, 1.0) * 255.0).toInt().coerceIn(1, 255)
      if (e.eventType.ordinal == 0) {
        val sharp = (e.parameters?.sharpness ?: 0.5).coerceIn(0.0, 1.0)
        val d = (10 + ((1.0 - sharp) * 40.0)).toLong()
        timings.add(d)
        amplitudes.add(intensity)
        t += d
      } else {
        val d = ((e.eventDuration ?: 0.2) * 1000.0).toLong().coerceAtLeast(1L)
        timings.add(d)
        amplitudes.add(intensity)
        t += d
      }
    }
    if (timings.isNotEmpty()) vibrateWave(timings.toLongArray(), amplitudes.toIntArray())
    Unit
  }

  private fun wave(durationsMs: LongArray, amps: IntArray) {
    vibrateWave(durationsMs, amps)
  }

  private fun vibrateWave(timings: LongArray, amplitudes: IntArray) {
    if (Build.VERSION.SDK_INT >= 26) {
      vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
    } else {
      @Suppress("DEPRECATION")
      vibrator.vibrate(timings.sum())
    }
  }
}