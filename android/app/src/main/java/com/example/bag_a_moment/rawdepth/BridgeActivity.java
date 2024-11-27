package com.example.bag_a_moment.rawdepth;

import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


public class BridgeActivity extends FlutterActivity {
    // Channel name
    private static final String CHANNEL = "com.example.example/message";

    // Result variable
    private MethodChannel.Result myResult;

    // Request code
    private static final int REQUEST_CODE = 1234;

    // Invoked method
    private void getVolumeAndroid() {
        Intent intent = new Intent(this, MainActivity.class);
        startActivityForResult(intent, REQUEST_CODE);
    }

    // Configure flutter engine
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Method channel
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            myResult = result;

                            // Invoked method handling
                            if (call.method.equals("getVolumeAndroid")) {
                                try {
                                    getVolumeAndroid();
                                } catch (Exception e) {
                                    myResult.error("Unavailable", "Opennig SecondActivity is not available", null);
                                }
                            } else {
                                myResult.notImplemented();
                            }
                        }
                );
    }

    // Activity result from invoked method
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                if (data == null) {
                    Log.e("Error", "data Intent is null");
                } else {
                    Log.d("Intent Data", "Width: " + data.getIntExtra("width", -1) +
                            ", Height: " + data.getIntExtra("height", -1) +
                            ", Depth: " + data.getIntExtra("depth", -1));
                }
                myResult.success("Width: " + data.getIntExtra("width", -1) +
                        ", Height: " + data.getIntExtra("height", -1) +
                        ", Depth: " + data.getIntExtra("depth", -1));
            } else {
                myResult.error("Unavailable", "짐 크기 정보 획득에 실패", null);
            }
        }
    }
}
