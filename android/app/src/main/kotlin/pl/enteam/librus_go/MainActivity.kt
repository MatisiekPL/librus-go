package pl.enteam.librus_go

import android.os.Bundle
import android.provider.Settings

import io.flutter.app.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {

  private val CHANNEL = "librus_go.enteam.pl/utils"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if(call.method == "checkIfInAutomatedTestsEnvironment") {
        val isInAutomatedTestsEnvironment = "true" == Settings.System.getString(contentResolver, "firebase.test.lab")
        result.success(isInAutomatedTestsEnvironment)
      }
    }
  }
}
