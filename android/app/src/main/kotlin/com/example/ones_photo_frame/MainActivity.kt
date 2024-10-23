package com.example.ones_photo_frame

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.ones_photo_frame/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImageToGallery") {
                val imageData = call.argument<ByteArray>("imageData")
                val fileName = call.argument<String>("fileName")
                if (imageData != null && fileName != null) {
                    saveImageToGallery(imageData, fileName)
                    result.success("Image saved successfully")
                } else {
                    result.error("INVALID_ARGUMENT", "Arguments were null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(imageData: ByteArray, fileName: String) {
        val resolver = contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/Ones")
            }
        }

        val imageUri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
        if (imageUri != null) {
            val fos: OutputStream? = resolver.openOutputStream(imageUri)
            fos?.use {
                it.write(imageData)
                it.flush()
            }
            Log.d("MainActivity", "Image saved to gallery: $fileName")
        } else {
            Log.e("MainActivity", "Failed to create new MediaStore record.")
        }
    }
}
