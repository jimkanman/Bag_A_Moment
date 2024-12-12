
package com.example.bag_a_moment.common.rendering;

import android.content.Context;
import android.opengl.GLES20;
import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;


public class ShaderUtil {

  public static int loadGLShader(String tag, Context context, int type, String filename)
      throws IOException {
    String code = readShaderFileFromAssets(context, filename);
    int shader = GLES20.glCreateShader(type);
    GLES20.glShaderSource(shader, code);
    GLES20.glCompileShader(shader);


    final int[] compileStatus = new int[1];
    GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, compileStatus, 0);


    if (compileStatus[0] == 0) {
      Log.e(tag, "Error compiling shader: " + GLES20.glGetShaderInfoLog(shader));
      GLES20.glDeleteShader(shader);
      shader = 0;
    }

    if (shader == 0) {
      throw new RuntimeException("Error creating shader.");
    }

    return shader;
  }


  public static void checkGLError(String tag, String label) {
    int lastError = GLES20.GL_NO_ERROR;

    int error;
    while ((error = GLES20.glGetError()) != GLES20.GL_NO_ERROR) {
      Log.e(tag, label + ": glError " + error);
      lastError = error;
    }
    if (lastError != GLES20.GL_NO_ERROR) {
      throw new RuntimeException(label + ": glError " + lastError);
    }
  }


  private static String readShaderFileFromAssets(Context context, String filename)
      throws IOException {
    try (InputStream inputStream = context.getAssets().open(filename);
        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
      StringBuilder sb = new StringBuilder();
      String line;
      while ((line = reader.readLine()) != null) {
        String[] tokens = line.split(" ", -1);
        if (tokens[0].equals("#include")) {
          String includeFilename = tokens[1];
          includeFilename = includeFilename.replace("\"", "");
          if (includeFilename.equals(filename)) {
            throw new IOException("Do not include the calling file.");
          }
          sb.append(readShaderFileFromAssets(context, includeFilename));
        } else {
          sb.append(line).append("\n");
        }
      }
      return sb.toString();
    }
  }
}
