package com.margelo.nitro.haptic

import android.content.Context
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager
import com.margelo.nitro.haptic.NitroHapticOnLoad

class NitroHapticPackage : ReactPackage {
  companion object {
    lateinit var appContext: Context
    init { NitroHapticOnLoad.initializeNative() }
  }

  override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
    appContext = reactContext.applicationContext
    return emptyList()
  }

  override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> = emptyList()
}
