package com.example.bag_a_moment.rawdepth;

import android.media.Image;
import android.opengl.Matrix;

import com.google.ar.core.Anchor;
import com.google.ar.core.CameraIntrinsics;
import com.google.ar.core.Frame;
import com.google.ar.core.Plane;
import com.google.ar.core.Pose;
import com.google.ar.core.TrackingState;
import com.google.ar.core.exceptions.NotYetAvailableException;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;
import java.util.Collection;

//깊이 이미지를 포인트 클라우드로 변환하는 클래스
public class DepthData {
    public static final int FLOATS_PER_POINT = 4; // X,Y,Z,confidence.

    //arcore frame을 받아 depth, confidence image를 이용하여 3D pointcloud를 생성
    public static FloatBuffer create(Frame frame, Anchor cameraPoseAnchor) {
        try {
            Image depthImage = frame.acquireRawDepthImage16Bits();
            Image confidenceImage = frame.acquireRawDepthConfidenceImage();

            final CameraIntrinsics intrinsics = frame.getCamera().getTextureIntrinsics();
            float[] modelMatrix = new float[16];
            cameraPoseAnchor.getPose().toMatrix(modelMatrix, 0);
            final FloatBuffer points = convertRawDepthImagesTo3dPointBuffer(
                    depthImage, confidenceImage, intrinsics, modelMatrix);

            depthImage.close();
            confidenceImage.close();

            return points;
        } catch (NotYetAvailableException e) {
            // This normally means that depth data is not available yet. This is normal so we will not
            // spam the logcat with this.
        }
        return null;
    }

    /** Applies camera intrinsics to convert depth image into a 3D pointcloud. */
    private static FloatBuffer convertRawDepthImagesTo3dPointBuffer(
            Image depth, Image confidence, CameraIntrinsics cameraTextureIntrinsics, float[] modelMatrix) {
        // Java uses big endian so we have to change the endianess to ensure we extract
        // depth data in the correct byte order.
        final Image.Plane depthImagePlane = depth.getPlanes()[0];
        ByteBuffer depthByteBufferOriginal = depthImagePlane.getBuffer();
        ByteBuffer depthByteBuffer = ByteBuffer.allocate(depthByteBufferOriginal.capacity());
        depthByteBuffer.order(ByteOrder.LITTLE_ENDIAN);
        while (depthByteBufferOriginal.hasRemaining()) {
            depthByteBuffer.put(depthByteBufferOriginal.get());
        }
        depthByteBuffer.rewind();
        ShortBuffer depthBuffer = depthByteBuffer.asShortBuffer();

        final Image.Plane confidenceImagePlane = confidence.getPlanes()[0];
        ByteBuffer confidenceBufferOriginal = confidenceImagePlane.getBuffer();
        ByteBuffer confidenceBuffer = ByteBuffer.allocate(confidenceBufferOriginal.capacity());
        confidenceBuffer.order(ByteOrder.LITTLE_ENDIAN);
        while (confidenceBufferOriginal.hasRemaining()) {
            confidenceBuffer.put(confidenceBufferOriginal.get());
        }
        confidenceBuffer.rewind();

        final int[] intrinsicsDimensions = cameraTextureIntrinsics.getImageDimensions();
        final int depthWidth = depth.getWidth();
        final int depthHeight = depth.getHeight();
        final float fx =
                cameraTextureIntrinsics.getFocalLength()[0] * depthWidth / intrinsicsDimensions[0];
        final float fy =
                cameraTextureIntrinsics.getFocalLength()[1] * depthHeight / intrinsicsDimensions[1];
        final float cx =
                cameraTextureIntrinsics.getPrincipalPoint()[0] * depthWidth / intrinsicsDimensions[0];
        final float cy =
                cameraTextureIntrinsics.getPrincipalPoint()[1] * depthHeight / intrinsicsDimensions[1];


        final float maxNumberOfPointsToRender = 20000;
        int step = (int) Math.ceil(Math.sqrt(depthWidth * depthHeight / maxNumberOfPointsToRender));

        FloatBuffer points = FloatBuffer.allocate(depthWidth / step * depthHeight / step * FLOATS_PER_POINT);
        float[] pointCamera = new float[4];
        float[] pointWorld = new float[4];

        for (int y = 0; y < depthHeight; y += step) {
            for (int x = 0; x < depthWidth; x += step) {
                // Depth images are tightly packed, so it's OK to not use row and pixel strides.
                int depthMillimeters = depthBuffer.get(y * depthWidth + x); // Depth image pixels are in mm.
                if (depthMillimeters == 0) {
                    // Pixels with value zero are invalid, meaning depth estimates are missing from
                    // this location.
                    continue;
                }
                final float depthMeters = depthMillimeters / 1000.0f; // Depth image pixels are in mm.

                // Retrieves the confidence value for this pixel.
                final byte confidencePixelValue =
                        confidenceBuffer.get(
                                y * confidenceImagePlane.getRowStride()
                                        + x * confidenceImagePlane.getPixelStride());
                final float confidenceNormalized = ((float) (confidencePixelValue & 0xff)) / 255.0f;
                if (confidenceNormalized < 0.3 || depthMeters > 1.5) {
                    // Ignores "low-confidence" pixels.
                    continue;
                }

                // Unprojects the depth into a 3D point in camera coordinates.
                pointCamera[0] = depthMeters * (x - cx) / fx;
                pointCamera[1] = depthMeters * (cy - y) / fy;
                pointCamera[2] = -depthMeters;
                pointCamera[3] = 1;

                // Applies model matrix to transform point into world coordinates.
                Matrix.multiplyMV(pointWorld, 0, modelMatrix, 0, pointCamera, 0);
                points.put(pointWorld[0]); // X.
                points.put(pointWorld[1]); // Y.
                points.put(pointWorld[2]); // Z.
                points.put(confidenceNormalized);
            }
        }

        points.rewind();
        return points;
    }

    public static void filterUsingPlanes(FloatBuffer points, Collection<Plane> allPlanes) {
        float[] planeNormal = new float[3];

        // Allocates the output buffer.
        int numPoints = points.remaining() / DepthData.FLOATS_PER_POINT;

        // Each plane is checked against each point.
        for (Plane plane : allPlanes) {
            if (plane.getTrackingState() != TrackingState.TRACKING || plane.getSubsumedBy() != null) {
                continue;
            }

            // Computes the normal vector of the plane.
            Pose planePose = plane.getCenterPose();
            planePose.getTransformedAxis(1, 1.0f, planeNormal, 0);

            // Filters points that are too close to the plane.
            for (int index = 0; index < numPoints; ++index) {
                // Retrieves the next point.
                final float x = points.get(FLOATS_PER_POINT * index);
                final float y = points.get(FLOATS_PER_POINT * index + 1);
                final float z = points.get(FLOATS_PER_POINT * index + 2);

                // Transforms point to be in world coordinates, to match plane info.
                float distance = (x - planePose.tx()) * planeNormal[0]
                        + (y - planePose.ty()) * planeNormal[1]
                        + (z - planePose.tz()) * planeNormal[2];

                if (Math.abs(distance) > 0.03) {
                    continue;  // Keeps this point, since it's far enough away from the plane.
                }

                // Invalidates points that are too close to planar surfaces.
                points.put(FLOATS_PER_POINT * index, 0);
                points.put(FLOATS_PER_POINT * index + 1, 0);
                points.put(FLOATS_PER_POINT * index + 2, 0);
                points.put(FLOATS_PER_POINT * index + 3, 0);
            }
        }
    }
}
