package pl.enteam.librus_go

import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.androidalarmmanager.AlarmService
import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
import io.sentry.android.AndroidSentryClientFactory
import io.sentry.Sentry


class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        Sentry.init("https://b31fd2f23caa45e2b999a3ccc9f81d35@sentry.io/1869678", AndroidSentryClientFactory(this))
        FlutterFirebaseMessagingService.setPluginRegistrant(this)
        AlarmService.setPluginRegistrant(this)
    }

    override fun registerWith(registry: PluginRegistry) {
        GeneratedPluginRegistrant.registerWith(registry)
    }
}
