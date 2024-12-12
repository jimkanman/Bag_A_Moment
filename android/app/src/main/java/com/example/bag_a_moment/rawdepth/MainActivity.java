package com.example.bag_a_moment.rawdepth;

import android.content.Intent;
import android.net.Uri;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;


import androidx.appcompat.app.AppCompatActivity;

import com.example.bag_a_moment.R;
import com.example.bag_a_moment.common.helpers.AABB;
import com.example.bag_a_moment.common.helpers.CameraPermissionHelper;
import com.example.bag_a_moment.common.helpers.DisplayRotationHelper;
import com.example.bag_a_moment.common.helpers.FullScreenHelper;
import com.example.bag_a_moment.common.helpers.PointClusteringHelper;
import com.example.bag_a_moment.common.helpers.SnackbarHelper;
import com.example.bag_a_moment.common.helpers.TrackingStateHelper;
import com.example.bag_a_moment.common.rendering.BackgroundRenderer;
import com.example.bag_a_moment.common.rendering.BoxRenderer;
import com.example.bag_a_moment.common.rendering.DepthRenderer;
import com.google.ar.core.ArCoreApk;
import com.google.ar.core.Camera;
import com.google.ar.core.Config;
import com.google.ar.core.Frame;
import com.google.ar.core.Plane;
import com.google.ar.core.Session;
import com.google.ar.core.TrackingState;
import com.google.ar.core.exceptions.CameraNotAvailableException;
import com.google.ar.core.exceptions.UnavailableApkTooOldException;
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException;
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException;
import com.google.ar.core.exceptions.UnavailableSdkTooOldException;
import com.google.ar.core.exceptions.UnavailableUserDeclinedInstallationException;

import java.io.IOException;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;


public class MainActivity extends AppCompatActivity implements GLSurfaceView.Renderer {
    private static final String TAG = MainActivity.class.getSimpleName();

    private GLSurfaceView surfaceView;
    private LinearLayout guide_text_container;
    private LinearLayout result_popup_container;
    private TextView result_text;
    private Button retrybtn;
    private Button confirmbtn;

    private boolean installRequested;

    private Session session;
    private final SnackbarHelper messageSnackbarHelper = new SnackbarHelper();
    private DisplayRotationHelper displayRotationHelper;

    private final DepthRenderer depthRenderer = new DepthRenderer();
    private final BackgroundRenderer backgroundRenderer = new BackgroundRenderer();
    private final BoxRenderer boxRenderer = new BoxRenderer();


    private static final int DEPTH_BUFFER_SIZE = 16;

    private AABB selectedCluster;
    private List<AABB> fixedClusters = new ArrayList<>();

    private Camera lastCamera;
    private Frame lastFrame;
    private FloatBuffer lastPoints;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        surfaceView = findViewById(R.id.surfaceview);
        guide_text_container = findViewById(R.id.guide_text_container);
        result_popup_container = findViewById(R.id.result_popup);
        result_text = findViewById(R.id.result_body);
        retrybtn = findViewById(R.id.retry_button);
        confirmbtn = findViewById(R.id.confirm_button);
        displayRotationHelper = new DisplayRotationHelper(this);


        surfaceView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                int touchActiion = motionEvent.getAction();
                if (touchActiion == MotionEvent.ACTION_DOWN) {
                    findClusterAtTouch(motionEvent.getX(), motionEvent.getY());
                } else if (touchActiion == MotionEvent.ACTION_MOVE) {
                    handleTouchMove(motionEvent.getX(), motionEvent.getY());
                }
                return true;
            }
        });
        retrybtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                selectedCluster = null;
                guide_text_container.setVisibility(View.VISIBLE);
                result_popup_container.setVisibility(View.GONE);
            }
        });
        confirmbtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (selectedCluster != null) {
                    Log.d("selectedCluster Debug", "Width: " + selectedCluster.getWidthInCm() +
                            ", Height: " + selectedCluster.getHeightInCm() +
                            ", Depth: " + selectedCluster.getDepthInCm());
                    Intent resultIntent = new Intent();
                    resultIntent.putExtra("width", (int)selectedCluster.getWidthInCm());
                    resultIntent.putExtra("height", (int)selectedCluster.getHeightInCm());
                    resultIntent.putExtra("depth", (int)selectedCluster.getDepthInCm());
                    resultIntent.setData(Uri.parse("Width: " + (int)selectedCluster.getWidthInCm() +
                    ", Height: " + (int)selectedCluster.getHeightInCm() +
                            ", Depth: " + (int)selectedCluster.getDepthInCm()));

                    Log.d("Intent Debug", "Width: " + selectedCluster.getWidthInCm() +
                            ", Height: " + selectedCluster.getHeightInCm() +
                            ", Depth: " + selectedCluster.getDepthInCm());
                    setResult(RESULT_OK, resultIntent);
                    finish();
                }
            }
        });

        // renderer 세팅
        surfaceView.setPreserveEGLContextOnPause(true);
        surfaceView.setEGLContextClientVersion(2);
        //깊이 버퍼 16비트로 설정
        surfaceView.setEGLConfigChooser(8, 8, 8, 8, DEPTH_BUFFER_SIZE, 0); // Alpha used for plane blending.
        surfaceView.setRenderer(this);
        //RENDERMODE_CONTINUOUSLY: GLSurfaceView가 활성화되어 있는 동안 계속해서 렌더링. 프레임을 그릴때마다 onDrawFrame()이 호출
        surfaceView.setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);
        surfaceView.setWillNotDraw(false);

        installRequested = false;
    }


    @Override
    protected void onResume() {
        super.onResume();

        // ARCore session이 없으면 생성

        if (session == null) {
            Exception exception = null;
            String message = null;
            // ARCore가 설치되어 있는지 확인
            try {
                switch (ArCoreApk.getInstance().requestInstall(this, !installRequested)) {
                    case INSTALL_REQUESTED:
                        installRequested = true;
                        return;
                    case INSTALLED:
                        break;
                }

                //카메라 권한이 없으면 요청
                if (!CameraPermissionHelper.hasCameraPermission(this)) {
                    CameraPermissionHelper.requestCameraPermission(this);
                    return;
                }

                // 세션 생성
                session = new Session(/* context= */ this);

                // Raw Depth 지원 여부 확인
                if (!session.isDepthModeSupported(Config.DepthMode.RAW_DEPTH_ONLY)) {
                    message =
                            "디바이스가 depth mode를 지원하지 않습니다.";
                }

            } catch (UnavailableArcoreNotInstalledException
                     | UnavailableUserDeclinedInstallationException e) {
                message = "ARCore 설치가 필요합니다";
                exception = e;
            } catch (UnavailableApkTooOldException e) {
                message = "ARCore 업데이트가 필요합니다";
                exception = e;
            } catch (UnavailableSdkTooOldException e) {
                message = "앱 업데이트가 필요합니다";
                exception = e;
            } catch (UnavailableDeviceNotCompatibleException e) {
                message = "디바이스가 AR을 지원하지 않습니다";
                exception = e;
            } catch (Exception e) {
                message = "알 수없는 오류로 세션 생성에 실패했습니다";
                exception = e;
            }

            //catch에서 걸린 에러 처리
            if (message != null) {
                messageSnackbarHelper.showError(this, message);
                Log.e(TAG, "Exception creating session", exception);
                return;
            }
        }

        try {
            // DepthMode 설정
            Config config = session.getConfig();
            //깊이 모드 설정
            config.setDepthMode(Config.DepthMode.RAW_DEPTH_ONLY);
            //자동 초점
            config.setFocusMode(Config.FocusMode.AUTO);
            session.configure(config);
            session.resume();
        } catch (CameraNotAvailableException e) {
            messageSnackbarHelper.showError(this, "카메라를 사용할 수 없습니다. 앱을 재시작해주세요.");
            session = null;
            return;
        }

        // GLSurfaceView와 DisplayRotationHelper를 재개
        surfaceView.onResume();
        displayRotationHelper.onResume();
        guide_text_container.setVisibility(View.VISIBLE);
    }

    @Override
    public void onPause() {
        super.onPause();
        if (session != null) {
            // GLSurfaceView가 먼저 일시 중지되어야 session.update가 호출되는 것을 막을 수 있음
            displayRotationHelper.onPause();
            surfaceView.onPause();
            session.pause();
        }
    }

    // 권한 요청에 응답했을 때 호출
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] results) {
        if (!CameraPermissionHelper.hasCameraPermission(this)) {
            Toast.makeText(this, "해당 기능을 이용하기위해 카메라 권한이 필요합니다",
                    Toast.LENGTH_LONG).show();
            //다시 묻지 않기를 선택한 경우
            if (!CameraPermissionHelper.shouldShowRequestPermissionRationale(this)) {
                //권한 설정화면으로 이동
                CameraPermissionHelper.launchPermissionSettings(this);
            }
            //권한 설정 안했으면 앱 종료
            finish();
        }
    }

    // 화면에 포커스가 있을 때 호출
    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        FullScreenHelper.setFullScreenOnWindowFocusChanged(this, hasFocus);
    }

    //
    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        //초기 렌더링 화면 색
        GLES20.glClearColor(0.1f, 0.1f, 0.1f, 1.0f);

        try {
            backgroundRenderer.createOnGlThread(this);
            depthRenderer.createOnGlThread(this);
            boxRenderer.createOnGlThread(this);
        } catch (IOException e) {
            Log.e(TAG, "Failed to read an asset file", e);
        }
    }

    // 화면 크기 변경 시 호출
    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        displayRotationHelper.onSurfaceChanged(width, height);
        //뷰포트 전체화면으로 고정
        GLES20.glViewport(0, 0, width, height);
    }


    @Override
    public void onDrawFrame(GL10 gl) {
        // 화면 지우기
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);

        //세션 확인
        if (session == null) {
            return;
        }

        //세션 업데이트. 화면 회전을 반영
        displayRotationHelper.updateSessionIfNeeded(session);

        try {
            //background renderer 에 카메라 텍스쳐(이미지)를 가져옴
            session.setCameraTextureName(backgroundRenderer.getTextureId());

            //현재 프레임을 가져오고 카메라 상태를 확인
            Frame frame = session.update();
            Camera camera = frame.getCamera();
            lastFrame = frame;
            lastCamera = camera;

            //카메라 이미지를 opengl표면에 렌더링
            backgroundRenderer.draw(frame);

            // 현재 프레임의 깊이 데이터를 가져옴
            FloatBuffer points = DepthData.create(frame, session.createAnchor(camera.getPose()));
            lastPoints = points;
            if (points == null) {
                return;
            }


            // 카메라 트레킹(카메라 이동에 대한 인식)이 되지 않으면 실패 이유를 보여줌
            if (camera.getTrackingState() == TrackingState.PAUSED) {
                messageSnackbarHelper.showMessage(
                        this, TrackingStateHelper.getTrackingFailureReasonString(camera));
                return;
            }

            //평면이 인식되면 깊이 데이터를 사용하여 평면을 제외한 나머지 데이터 만 필터링
            DepthData.filterUsingPlanes(points, session.getAllTrackables(Plane.class));

            //depth 시각화
            depthRenderer.update(points);
            depthRenderer.draw(camera);

            //포인트 클라우드를 통해 클라우드 감지. 클러스터링을 통해 AABB를 찾아서 그림
            //모든 클러스터 박스 출력
//            PointClusteringHelper clusteringHelper = new PointClusteringHelper(points);
//            List<AABB> clusters = clusteringHelper.findClusters();
//            for (AABB aabb : clusters) {
//                boxRenderer.draw(aabb, camera);
//            }

//            PointClusteringHelper clusteringHelper = new PointClusteringHelper(points);
//            AABB centeredCluster = clusteringHelper.findNearestClusterToCenter(screenToWorldCoordinates(surfaceView.getWidth()/2, surfaceView.getHeight()/2, points));
//            boxRenderer.draw(centeredCluster,camera);
//
//            //클러스터가 생성되었다면 snackbar로 메세지 출력
//            if (centeredCluster != null) {
//                messageSnackbarHelper.showMessage(this, "클러스터 감지됨: " );
//            }

//              PointClusteringHelper clusteringHelper = new PointClusteringHelper(points);
//              List<AABB> clusters = clusteringHelper.findNonOverlappingLargestClusters();
//              for (AABB aabb : clusters) {
//                boxRenderer.draw(aabb, camera);
//                }

//              // 안정적인 클러스터만 고정된 클러스터로 저장
//              for (AABB cluster : clusters) {
//                if (isStable(cluster)) {
//                  fixedClusters.add(cluster);
//                }
//              }
              // 고정된 클러스터는 그대로 렌더링
//              for (AABB fixedCluster : clusters) {
//                boxRenderer.draw(fixedCluster, camera);
//              }

            if (selectedCluster != null) {
                //터치로 선택된 박스를 렌더링
                boxRenderer.drawSelected(selectedCluster, camera);
            }
        } catch (Throwable t) {
            Log.e(TAG, "Exception on the OpenGL thread", t);
        }
    }

    private void handleTouchMove(float x, float y) {
        if (selectedCluster != null && lastPoints != null) {
            // 화면 좌표를 사용하여 새 위치를 계산
//            float[] newWorldCoords = screenToWorldCoordinates(x, y,lastPoints );
//            if (newWorldCoords != null) {
//                // 새 위치로 selectedCluster 이동
//                selectedCluster.setCenter(newWorldCoords[0], newWorldCoords[1], newWorldCoords[2]);
//            }
        }
    }


    private void findClusterAtTouch(float touchX, float touchY) {
        if (session == null || lastCamera == null || lastFrame == null) {
            return;
        }

        try {
            // 현재 프레임의 깊이 데이터에서 포인트 클라우드를 가져옵니다.
            FloatBuffer points = DepthData.create(lastFrame, session.createAnchor(lastCamera.getPose()));
            if (points == null) {
                return;
            }

            // 터치한 좌표를 월드 좌표로 변환
            float[] touchWorldCoords = screenToWorldCoordinates(touchX, touchY, points);
            if (touchWorldCoords == null) {
                return;
            }

            //전체 클러스터 목록 생성
            PointClusteringHelper clusteringHelper = new PointClusteringHelper(points);
            List<AABB> clusters = clusteringHelper.findClusters();
            AABB targetCluster = null;

            // 터치 위치를 포함하는 클러스터 탐색
            for (AABB cluster : clusters) {
                if (cluster.containsPoint(touchWorldCoords[0], touchWorldCoords[1], touchWorldCoords[2])) {
                    targetCluster = cluster;
                    break;
                }
            }

            // 찾은 클러스터를 선택된 클러스터로 설정하고 렌더링합니다.
            selectedCluster = targetCluster;
            if (selectedCluster != null) {
                messageSnackbarHelper.showMessage(this, "클러스터 선택됨");
                guide_text_container.setVisibility(View.GONE);
                result_popup_container.setVisibility(View.VISIBLE);
                result_text.setText("가로" + (int) selectedCluster.getWidthInCm() + "세로" + (int) selectedCluster.getHeightInCm() + "높이" + (int) selectedCluster.getDepthInCm());
            } else {
                messageSnackbarHelper.showMessage(this, "클러스터 선택 실패");
            }
        } catch (Exception e) {
            Log.e(TAG, "Exception in findClusterA`tTouch: ", e);
        }
    }

    // 화면 좌표를 사용하여 깊이 데이터에서 3D 포인트 추출
    private float[] screenToWorldCoordinates(float screenX, float screenY, FloatBuffer points) {
        if (points == null) {
            return null;
        }
        //월드좌표 이용
        // NDC (Normalized Device Coordinates)로 변환
        float ndcX = (screenX / surfaceView.getWidth()) * 2.0f - 1.0f;
        float ndcY = (screenY / surfaceView.getHeight()) * -2.0f + 1.0f;

        float[] projectionMatrix = new float[16];
        lastCamera.getProjectionMatrix(projectionMatrix, 0, 0.1f, 100.0f); // Near: 0.1, Far: 100.0

        float[] viewMatrix = new float[16];
        lastCamera.getViewMatrix(viewMatrix, 0);

        // NDC에서 카메라 좌표로 변환
        float[] clipCoords = new float[]{ndcX, ndcY, -1.0f, 1.0f};
        float[] invertedVPMatrix = new float[16];
        float[] worldCoords = new float[4];

        // 뷰-투영 행렬을 역행렬로 변환하여 NDC를 월드 좌표로 변환
        float[] vpMatrix = new float[16];
        Matrix.multiplyMM(vpMatrix, 0, projectionMatrix, 0, viewMatrix, 0);
        Matrix.invertM(invertedVPMatrix, 0, vpMatrix, 0);
        Matrix.multiplyMV(worldCoords, 0, invertedVPMatrix, 0, clipCoords, 0);

        // Homogeneous divide to get actual world coordinates
        worldCoords[0] /= worldCoords[3];
        worldCoords[1] /= worldCoords[3];
        worldCoords[2] /= worldCoords[3];

        // 변환된 월드 좌표와 가까운 포인트 찾기
        float[] closestPoint = null;
        float minDistance = Float.MAX_VALUE;


        while (points.hasRemaining()) {
            float px = points.get();
            float py = points.get();
            float pz = points.get();
            float confidence = points.get();

            if (confidence > 0.5f) {
                float distance = (float) Math.sqrt(
                        Math.pow(px - worldCoords[0], 2) +
                                Math.pow(py - worldCoords[1], 2) +
                                Math.pow(pz - worldCoords[2], 2)
                );
                if (distance < minDistance) {
                    minDistance = distance;
                    closestPoint = new float[]{px, py, pz};
                }
            }
        }
        return closestPoint;
    }
}
