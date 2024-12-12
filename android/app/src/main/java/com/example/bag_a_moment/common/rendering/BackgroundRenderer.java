
package com.example.bag_a_moment.common.rendering;

import android.content.Context;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;

import androidx.annotation.NonNull;

import com.google.ar.core.Coordinates2d;
import com.google.ar.core.Frame;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;


public class BackgroundRenderer {
  private static final String TAG = BackgroundRenderer.class.getSimpleName();

  private static final String CAMERA_VERTEX_SHADER_NAME = "shaders/screenquad.vert";
  private static final String CAMERA_FRAGMENT_SHADER_NAME = "shaders/screenquad.frag";

  private static final int COORDS_PER_VERTEX = 2;
  private static final int TEXCOORDS_PER_VERTEX = 2;
  private static final int FLOAT_SIZE = 4;

  private FloatBuffer quadCoords;
  private FloatBuffer quadTexCoords;

  private int quadProgram;

  private int quadPositionParam;
  private int quadTexCoordParam;
  private int textureId = -1;

  public int getTextureId() {
    return textureId;
  }


  public void createOnGlThread(Context context) throws IOException {
    // Generate the background texture.
    int[] textures = new int[1];
    GLES20.glGenTextures(1, textures, 0);
    textureId = textures[0];
    int textureTarget = GLES11Ext.GL_TEXTURE_EXTERNAL_OES;
    GLES20.glBindTexture(textureTarget, textureId);
    GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
    GLES20.glTexParameteri(textureTarget, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);

    int numVertices = 4;
    if (numVertices != QUAD_COORDS.length / COORDS_PER_VERTEX) {
      throw new RuntimeException("Unexpected number of vertices in BackgroundRenderer.");
    }

    ByteBuffer bbCoords = ByteBuffer.allocateDirect(QUAD_COORDS.length * FLOAT_SIZE);
    bbCoords.order(ByteOrder.nativeOrder());
    quadCoords = bbCoords.asFloatBuffer();
    quadCoords.put(QUAD_COORDS);
    quadCoords.position(0);

    ByteBuffer bbTexCoordsTransformed =
        ByteBuffer.allocateDirect(numVertices * TEXCOORDS_PER_VERTEX * FLOAT_SIZE);
    bbTexCoordsTransformed.order(ByteOrder.nativeOrder());
    quadTexCoords = bbTexCoordsTransformed.asFloatBuffer();

    int vertexShader =
        ShaderUtil.loadGLShader(TAG, context, GLES20.GL_VERTEX_SHADER, CAMERA_VERTEX_SHADER_NAME);
    int fragmentShader =
        ShaderUtil.loadGLShader(TAG, context, GLES20.GL_FRAGMENT_SHADER, CAMERA_FRAGMENT_SHADER_NAME);

    quadProgram = GLES20.glCreateProgram();
    GLES20.glAttachShader(quadProgram, vertexShader);
    GLES20.glAttachShader(quadProgram, fragmentShader);
    GLES20.glLinkProgram(quadProgram);
    GLES20.glUseProgram(quadProgram);

    ShaderUtil.checkGLError(TAG, "Program creation");

    quadPositionParam = GLES20.glGetAttribLocation(quadProgram, "a_Position");
    quadTexCoordParam = GLES20.glGetAttribLocation(quadProgram, "a_TexCoord");

    ShaderUtil.checkGLError(TAG, "Program parameters");
  }

  public void draw(@NonNull Frame frame) {
    if (frame.hasDisplayGeometryChanged()) {
      frame.transformCoordinates2d(
          Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES,
          quadCoords,
          Coordinates2d.TEXTURE_NORMALIZED,
          quadTexCoords);
    }

    if (frame.getTimestamp() == 0) {
      return;
    }

    draw();
  }

  private void draw() {

    quadTexCoords.position(0);


    GLES20.glDisable(GLES20.GL_DEPTH_TEST);
    GLES20.glDepthMask(false);

    GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
    GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId);

    GLES20.glUseProgram(quadProgram);


    GLES20.glVertexAttribPointer(
        quadPositionParam, COORDS_PER_VERTEX, GLES20.GL_FLOAT, false, 0, quadCoords);


    GLES20.glVertexAttribPointer(
        quadTexCoordParam, TEXCOORDS_PER_VERTEX, GLES20.GL_FLOAT, false, 0, quadTexCoords);


    GLES20.glEnableVertexAttribArray(quadPositionParam);
    GLES20.glEnableVertexAttribArray(quadTexCoordParam);

    GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);


    GLES20.glDisableVertexAttribArray(quadPositionParam);
    GLES20.glDisableVertexAttribArray(quadTexCoordParam);


    GLES20.glDepthMask(true);
    GLES20.glEnable(GLES20.GL_DEPTH_TEST);

    ShaderUtil.checkGLError(TAG, "BackgroundRendererDraw");
  }


  private static final float[] QUAD_COORDS =
      new float[] {
        -1.0f, -1.0f, +1.0f, -1.0f, -1.0f, +1.0f, +1.0f, +1.0f,
      };
}
