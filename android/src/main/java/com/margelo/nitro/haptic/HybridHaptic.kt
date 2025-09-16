package com.margelo.nitro.haptic

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import com.facebook.proguard.annotations.DoNotStrip
import com.margelo.nitro.react.NitroModules

@DoNotStrip
class HybridHaptic : HybridHapticSpec() {
  private val vibrator: Vibrator

  init {
    val ctx = NitroModules.applicationContext
    vibrator = if (Build.VERSION.SDK_INT >= 31) {
      val vm = ctx.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
      vm.defaultVibrator
    } else {
      ctx.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
    }
  }

  override fun isAvailable(): Boolean = vibrator.hasVibrator()

  private fun predefined(effect: Int, fallbackMs: Int) {
    if (Build.VERSION.SDK_INT >= 29) {
      vibrator.vibrate(VibrationEffect.createPredefined(effect))
    } else {
      vibrator.vibrate(fallbackMs.toLong())
    }
  }

  private fun wave(times: LongArray, amps: IntArray) {
    if (Build.VERSION.SDK_INT >= 26) {
      vibrator.vibrate(VibrationEffect.createWaveform(times, amps, -1))
    } else {
      vibrator.vibrate(times.sum())
    }
  }

  override fun notify(preset: HapticPreset) {
    when (preset) {
      HapticPreset.SELECTION -> wave(longArrayOf(12), intArrayOf(110))
      HapticPreset.IMPACTLIGHT -> wave(longArrayOf(14, 10), intArrayOf(140, 60))
      HapticPreset.IMPACTMEDIUM -> wave(longArrayOf(18, 12), intArrayOf(190, 90))
      HapticPreset.IMPACTHEAVY -> wave(longArrayOf(24, 16), intArrayOf(255, 120))
      HapticPreset.IMPACTSOFT -> wave(longArrayOf(8, 14, 18), intArrayOf(70, 130, 80))
      HapticPreset.IMPACTRIGID -> wave(longArrayOf(10, 8), intArrayOf(255, 120))
      HapticPreset.NOTIFICATIONSUCCESS -> wave(longArrayOf(20, 40, 28), intArrayOf(150, 0, 230))
      HapticPreset.NOTIFICATIONWARNING -> wave(longArrayOf(26, 36, 22), intArrayOf(220, 0, 220))
      HapticPreset.NOTIFICATIONERROR -> wave(longArrayOf(28, 40, 36), intArrayOf(255, 0, 160))
    }
  }

  override fun play(pattern: HapticPattern) {
    val events = pattern.events.sortedBy { it.time }
    val timings = ArrayList<Long>()
    val amps = ArrayList<Int>()
    var last = 0L
    for (e in events) {
      val at = (e.time * 1000.0).toLong()
      val gap = (at - last).coerceAtLeast(0L)
      if (gap > 0) {
        timings.add(gap)
        amps.add(0)
        last += gap
      }
      val intensity = (e.parameters?.intensity ?: 1.0).coerceIn(0.0, 1.0)
      val amp = (intensity * 255.0).toInt().coerceIn(1, 255)
      when (e.eventType) {
        HapticEventType.hapticTransient -> {
          val d = 30L
          timings.add(d)
          amps.add(amp)
          last += d
        }
        HapticEventType.hapticContinuous -> {
          val d = ((e.eventDuration ?: 0.1) * 1000.0).toLong().coerceAtLeast(1L)
          timings.add(d)
          amps.add(amp)
          last += d
        }
      }
    }
    if (timings.isNotEmpty()) wave(timings.toLongArray(), amps.toIntArray())
  }
}
