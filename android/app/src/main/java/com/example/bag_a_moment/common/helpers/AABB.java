

package com.example.bag_a_moment.common.helpers;


public class AABB {
    public float minX = Float.MAX_VALUE;
    public float minY = Float.MAX_VALUE;
    public float minZ = Float.MAX_VALUE;
    public float maxX = -Float.MAX_VALUE;
    public float maxY = -Float.MAX_VALUE;
    public float maxZ = -Float.MAX_VALUE;

    public void update(float x, float y, float z) {
        minX = Math.min(x, minX);
        minY = Math.min(y, minY);
        minZ = Math.min(z, minZ);
        maxX = Math.max(x, maxX);
        maxY = Math.max(y, maxY);
        maxZ = Math.max(z, maxZ);
    }

    public float getVolume() {
        return (maxX - minX) * (maxY - minY) * (maxZ - minZ);
    }

    // 박스의 가로 크기를 cm 단위로 반환
    public float getWidthInCm() {
        return (maxX - minX) * 100; // m -> cm 변환
    }

    // 박스의 세로 크기를 cm 단위로 반환
    public float getHeightInCm() {
        return (maxY - minY) * 100; // m -> cm 변환
    }

    // 박스의 높이 크기를 cm 단위로 반환
    public float getDepthInCm() {
        return (maxZ - minZ) * 100; // m -> cm 변환
    }

    public boolean containsPoint(float x, float y, float z) {
        return (x >= minX && x <= maxX) &&
                (y >= minY && y <= maxY) &&
                (z >= minZ && z <= maxZ);
    }
}
