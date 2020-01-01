package pl.enteam.librus_go

import android.os.Bundle
import android.provider.Settings

import io.flutter.app.FlutterFragmentActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;
import android.icu.lang.UCharacter.GraphemeClusterBreak.T


class MainActivity : FlutterFragmentActivity(), PluginRegistry.PluginRegistrantCallback {

    private val CHANNEL = "librus_go.enteam.pl/utils"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        FlutterFirebaseMessagingService.setPluginRegistrant(this)

        MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "checkIfInAutomatedTestsEnvironment") {
                val isInAutomatedTestsEnvironment = "true" == Settings.System.getString(contentResolver, "firebase.test.lab")
                result.success(isInAutomatedTestsEnvironment)
            }
        }
    }

    override fun registerWith(registry: PluginRegistry) {
        GeneratedPluginRegistrant.registerWith(registry)
    }
}
