package com.example.app_medicare

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log

/**
 * Foreground service that loops a siren on the ALARM audio stream so the SOS
 * alarm keeps sounding when the app is backgrounded, the screen locks, or the
 * phone is in silent/DND mode. Runs until explicitly stopped via ACTION_STOP.
 */
class SosAlarmService : Service() {

    companion object {
        const val ACTION_START = "com.curalee.sos.alarm.START"
        const val ACTION_STOP = "com.curalee.sos.alarm.STOP"
        const val CHANNEL_ID = "curalee_sos_alarm"
        const val NOTIFICATION_ID = 9911
        private const val TAG = "SosAlarmService"

        @Volatile
        var isRunning: Boolean = false
            private set
    }

    private var mediaPlayer: MediaPlayer? = null
    private var wakeLock: PowerManager.WakeLock? = null
    private var originalAlarmVolume: Int = -1

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopAlarm()
                return START_NOT_STICKY
            }
            else -> startAlarm()
        }
        // If the OS kills us mid-alarm, restart so the siren resumes.
        return START_STICKY
    }

    private fun startAlarm() {
        if (isRunning) return
        isRunning = true

        startForeground(NOTIFICATION_ID, buildNotification())

        // Keep the CPU awake so playback continues with the screen off.
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "curalee:sos_alarm").apply {
            setReferenceCounted(false)
            acquire(60 * 60 * 1000L) // 1h safety cap; alarm is manually dismissed well before
        }

        // Max out the alarm stream so a turned-down alarm volume can't mute the SOS.
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        originalAlarmVolume = audioManager.getStreamVolume(AudioManager.STREAM_ALARM)
        try {
            audioManager.setStreamVolume(
                AudioManager.STREAM_ALARM,
                audioManager.getStreamMaxVolume(AudioManager.STREAM_ALARM),
                0,
            )
        } catch (e: SecurityException) {
            // Some OEMs block volume changes under strict DND; play at current volume.
            Log.w(TAG, "Could not raise alarm volume", e)
        }

        val alarmUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)

        try {
            mediaPlayer = MediaPlayer().apply {
                setAudioAttributes(
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_ALARM)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build(),
                )
                setDataSource(this@SosAlarmService, alarmUri)
                isLooping = true
                setOnPreparedListener { it.start() }
                prepareAsync()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start alarm playback", e)
            stopAlarm()
        }
    }

    private fun stopAlarm() {
        if (originalAlarmVolume >= 0) {
            try {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.setStreamVolume(AudioManager.STREAM_ALARM, originalAlarmVolume, 0)
            } catch (e: SecurityException) {
                Log.w(TAG, "Could not restore alarm volume", e)
            }
            originalAlarmVolume = -1
        }
        mediaPlayer?.run {
            try {
                if (isPlaying) stop()
            } catch (_: IllegalStateException) {
            }
            release()
        }
        mediaPlayer = null
        wakeLock?.let { if (it.isHeld) it.release() }
        wakeLock = null
        isRunning = false
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun buildNotification(): Notification {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "SOS Alarm",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Shown while the SOS alarm siren is sounding"
                setSound(null, null) // sound comes from MediaPlayer, not the notification
                setBypassDnd(true)
            }
            manager.createNotificationChannel(channel)
        }

        val openAppIntent = PendingIntent.getActivity(
            this,
            0,
            packageManager.getLaunchIntentForPackage(packageName),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val stopIntent = PendingIntent.getService(
            this,
            1,
            Intent(this, SosAlarmService::class.java).setAction(ACTION_STOP),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setContentTitle("🚨 SOS alarm active")
            .setContentText("Emergency contacts have been alerted. Tap to open.")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setOngoing(true)
            .setContentIntent(openAppIntent)
            .addAction(
                Notification.Action.Builder(null, "STOP ALARM", stopIntent).build(),
            )
            .build()
    }

    override fun onDestroy() {
        stopAlarm()
        super.onDestroy()
    }
}
