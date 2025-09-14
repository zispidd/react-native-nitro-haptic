package com.margelo.nitro.nitrohaptic
  
import com.facebook.proguard.annotations.DoNotStrip

@DoNotStrip
class NitroHaptic : HybridNitroHapticSpec() {
  override fun multiply(a: Double, b: Double): Double {
    return a * b
  }
}
