package com.example.app_medicare

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.TelephonyManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val SOS_CHANNEL = "com.curalee.sos"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SOS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startAlarmSound" -> {
                        val intent = Intent(this, SosAlarmService::class.java)
                            .setAction(SosAlarmService.ACTION_START)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(intent)
                        } else {
                            startService(intent)
                        }
                        result.success(true)
                    }

                    "stopAlarmSound" -> {
                        startService(
                            Intent(this, SosAlarmService::class.java)
                                .setAction(SosAlarmService.ACTION_STOP),
                        )
                        result.success(true)
                    }

                    "isAlarmPlaying" -> result.success(SosAlarmService.isRunning)

                    "hasSmsSupport" -> {
                        val hasTelephony =
                            packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)
                        val tm = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                        val simReady = tm.simState == TelephonyManager.SIM_STATE_READY
                        result.success(hasTelephony && simReady)
                    }

                    "sendSms" -> {
                        val phones = call.argument<List<String>>("phones")
                        val message = call.argument<String>("message")
                        if (phones.isNullOrEmpty() || message.isNullOrEmpty()) {
                            result.error("BAD_ARGS", "phones and message are required", null)
                            return@setMethodCallHandler
                        }
                        result.success(sendSmsToAll(phones, message))
                    }

                    "isIgnoringBatteryOptimizations" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }

                    "requestIgnoreBatteryOptimizations" -> {
                        try {
                            startActivity(
                                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                                    .setData(Uri.parse("package:$packageName")),
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    /**
     * Sends [message] to every number via raw cellular SMS (no data connection
     * needed). Returns a map of phone -> "sent" | "failed:<reason>" so the Dart
     * side can show exactly who was reached. Requires SEND_SMS to be granted.
     */
    private fun sendSmsToAll(phones: List<String>, message: String): Map<String, String> {
        val smsManager: SmsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            getSystemService(SmsManager::class.java)
        } else {
            @Suppress("DEPRECATION")
            SmsManager.getDefault()
        }

        val results = mutableMapOf<String, String>()
        for (phone in phones) {
            try {
                val parts = smsManager.divideMessage(message)
                if (parts.size > 1) {
                    smsManager.sendMultipartTextMessage(phone, null, parts, null, null)
                } else {
                    smsManager.sendTextMessage(phone, null, message, null, null)
                }
                results[phone] = "sent"
            } catch (e: Exception) {
                results[phone] = "failed:${e.message ?: e.javaClass.simpleName}"
            }
        }
        return results
    }
}
