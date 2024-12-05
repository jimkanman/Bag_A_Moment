/*
 * Copyright 2021 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.bag_a_moment.common.helpers;

import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class PointClusteringHelper {
    // The resolution of the grid to allocate.  A smaller size means higher fidelity, but also
    // incurs a larger memory footprint.
    private static final float GRID_CELL_SIZE = 0.05f; // Units: meters.

    // Clusters with fewer than this many elements are ignored.
    private static final int MIN_CLUSTER_ELEMENTS = 10;

    // 최대 크기 제한 설정 (단위: cm, 예시)
    private static final float MAX_CLUSTER_WIDTH = 100.0f;
    private static final float MAX_CLUSTER_HEIGHT = 100.0f;
    private static final float MAX_CLUSTER_DEPTH =100.0f;
    // 최대 크기 제한 설정 (단위: cm, 예시)
    private static final float MIN_CLUSTER_WIDTH = 10.0f;
    private static final float MIN_CLUSTER_HEIGHT = 10.0f;
    private static final float MIN_CLUSTER_DEPTH = 10.0f;


    // The occupancy grid represents voxels in 3D space.  Each voxel is marked 'true' iff a depth
    // point with high confidence intersects it.  This grid volume represents a cuboid in space
    // defined by the bounding box of the pointcloud.
    private boolean[][][] occupancyGrid;

    // The translational offset of the grid relative to the world coordinates.  This offset is
    // necessary for cases when the bounding box of depth points don't overlap the origin.  This
    // value is equivalent to the minimum corner of the point cloud bounding box.
    private float[] gridOriginOffset = new float[3];

    public PointClusteringHelper(FloatBuffer points) {
        allocateGrid(points);
    }

    /**
     * Finds clusters of voxels.  Computes a list of axis-aligned bounding boxes representing
     * large areas of depth points.
     */
    public List<AABB> findClusters() {
        // Clusters are found by iterating over each cell's neighbors.  As cells are found, they are
        // marked false.  This process continues until all cells are false.
        // Because the original grid is modified, this call will only produce results once.
        List<AABB> clusters = new ArrayList<>();
        List<AABB> filterdclusters = new ArrayList<>();
        List<int[]> currentCluster = new ArrayList<>();

        // Searches the grid for clusters.
        int[] index = new int[3];
        for (index[0] = 0; index[0] < occupancyGrid.length; ++index[0]) {
            for (index[1] = 0; index[1] < occupancyGrid[0].length; ++index[1]) {
                for (index[2] = 0; index[2] < occupancyGrid[0][0].length; ++index[2]) {
                    // Attempts to find a cluster containing the current index.
                    depthFirstSearch(index, occupancyGrid, currentCluster);
                    if (currentCluster.size() >= MIN_CLUSTER_ELEMENTS) {
                        // Stores the cluster.
                        clusters.add(computeAABB(currentCluster));
                        currentCluster.clear();
                    }
                }
            }
        }
        for (AABB cluster : clusters) {
            float width = cluster.getWidthInCm();
            float height = cluster.getHeightInCm();
            float depth = cluster.getDepthInCm();

            // 클러스터의 크기가 제한 기준 이내인 경우에만 clusters에 추가
            if (width <= MAX_CLUSTER_WIDTH && height <= MAX_CLUSTER_HEIGHT && depth <= MAX_CLUSTER_DEPTH
            &&width >= MIN_CLUSTER_WIDTH && height >= MIN_CLUSTER_HEIGHT && depth >= MIN_CLUSTER_DEPTH) {
                filterdclusters.add(cluster);
            }
        }

        return filterdclusters;
    }
    public AABB findNearestClusterToCenter(float[] screenCenterWorldCoords) {
        // 모든 포인트에 대해 클러스터링 수행
        List<AABB> clusters = findClusters();

        AABB nearestCluster = null;
        float minDistance = Float.MAX_VALUE;

        // 각 클러스터의 중심과 화면 중심 좌표 간의 거리 계산
        for (AABB cluster : clusters) {
            // 클러스터의 중심 좌표 계산
            float centerX = (cluster.minX + cluster.maxX) / 2;
            float centerY = (cluster.minY + cluster.maxY) / 2;
            float centerZ = (cluster.minZ + cluster.maxZ) / 2;

            // 화면 중심과 클러스터 중심 간의 거리 계산
            float distance = (float) Math.sqrt(
                    Math.pow(centerX - screenCenterWorldCoords[0], 2) +
                            Math.pow(centerY - screenCenterWorldCoords[1], 2) +
                            Math.pow(centerZ - screenCenterWorldCoords[2], 2)
            );

            // 가장 가까운 클러스터 업데이트
            if (distance < minDistance) {
                minDistance = distance;
                nearestCluster = cluster;
            }
        }

        return nearestCluster;
    }
    /** Finds the bounding box of all points, allocating a 3D grid of sufficient size. */
    private void allocateGrid(FloatBuffer points) {
        // Finds the min/max bounds of the pointcloud.
        AABB bounds = new AABB();
        points.rewind();
        while (points.hasRemaining()) {
            float x = points.get();
            float y = points.get();
            float z = points.get();
            float confidence = points.get();
            if (confidence <= 0) {
                continue;
            }
            bounds.update(x, y, z);
        }

        // Each grid cell is a cube of size GRID_CELL_SIZE^3 cubic meters.
        gridOriginOffset[0] = bounds.minX;
        gridOriginOffset[1] = bounds.minY;
        gridOriginOffset[2] = bounds.minZ;
        int numCellsX = Math.max(1, (int) Math.ceil((bounds.maxX - bounds.minX) / GRID_CELL_SIZE));
        int numCellsY = Math.max(1, (int) Math.ceil((bounds.maxY - bounds.minY) / GRID_CELL_SIZE));
        int numCellsZ = Math.max(1, (int) Math.ceil((bounds.maxZ - bounds.minZ) / GRID_CELL_SIZE));
        occupancyGrid = new boolean[numCellsX][numCellsY][numCellsZ];

        // Populates the grid with occupancy of points.
        points.rewind();
        while (points.hasRemaining()) {
            float x = points.get();
            float y = points.get();
            float z = points.get();
            float confidence = points.get();
            if (confidence <= 0) {
                continue;
            }

            // Finds the voxel that contains this depth point and sets it to true.
            int indexX = (int) Math.floor((x - gridOriginOffset[0]) / GRID_CELL_SIZE);
            int indexY = (int) Math.floor((y - gridOriginOffset[1]) / GRID_CELL_SIZE);
            int indexZ = (int) Math.floor((z - gridOriginOffset[2]) / GRID_CELL_SIZE);
            occupancyGrid[indexX][indexY][indexZ] = true;
        }
    }

    /** Computes the metric bounds of a subset of the grid. */
    private AABB computeAABB(List<int[]> cluster) {
        // Computes the bounds in units of "indices".
        AABB bounds = new AABB();
        for (int[] index : cluster) {
            // The minimum and maximum corners of this grid cell, in units of indices.
            bounds.update(index[0], index[1], index[2]);
            bounds.update(index[0]+1, index[1]+1, index[2]+1);
        }

        // Rescales units from "indices" to "meters".
        bounds.minX = GRID_CELL_SIZE * bounds.minX + gridOriginOffset[0];
        bounds.minY = GRID_CELL_SIZE * bounds.minY + gridOriginOffset[1];
        bounds.minZ = GRID_CELL_SIZE * bounds.minZ + gridOriginOffset[2];
        bounds.maxX = GRID_CELL_SIZE * bounds.maxX + gridOriginOffset[0];
        bounds.maxY = GRID_CELL_SIZE * bounds.maxY + gridOriginOffset[1];
        bounds.maxZ = GRID_CELL_SIZE * bounds.maxZ + gridOriginOffset[2];

        return bounds;
    }

    private static void depthFirstSearch(int[] index, boolean[][][] grid, List<int[]> cluster) {
        if (!inBounds(index, grid) || !grid[index[0]][index[1]][index[2]]) {
            return;  // Not occupied, stop searching in this area.
        }

        // Since the current index is occupied, it can be added to the local cluster. Once added,
        // we reset the grid to avoid cyclic behavior.
        grid[index[0]][index[1]][index[2]] = false;
        cluster.add(index.clone());

        // Search the neighbors.
        depthFirstSearch(new int[]{index[0]-1, index[1], index[2]}, grid, cluster);
        depthFirstSearch(new int[]{index[0]+1, index[1], index[2]}, grid, cluster);
        depthFirstSearch(new int[]{index[0], index[1]-1, index[2]}, grid, cluster);
        depthFirstSearch(new int[]{index[0], index[1]+1, index[2]}, grid, cluster);
        depthFirstSearch(new int[]{index[0], index[1], index[2]-1}, grid, cluster);
        depthFirstSearch(new int[]{index[0], index[1], index[2]+1}, grid, cluster);
    }

    private static boolean inBounds(int[] index, boolean[][][] grid) {
        return index[0] >= 0 && index[0] < grid.length &&
                index[1] >= 0 && index[1] < grid[0].length &&
                index[2] >= 0 && index[2] < grid[0][0].length;
    }

    public List<AABB> findNonOverlappingLargestClusters() {
        List<AABB> clusters = findClusters(); // 기본 클러스터링 수행
        List<AABB> nonOverlappingClusters = new ArrayList<>();

        for (AABB current : clusters) {
            boolean isLargest = true;
            Iterator<AABB> iterator = nonOverlappingClusters.iterator();

            while (iterator.hasNext()) {
                AABB existing = iterator.next();
                if (isOverlapping(current, existing)) {
                    // 겹치는 경우, 현재 클러스터가 기존 클러스터보다 작은지 확인
                    if (current.getVolume() <= existing.getVolume()) {
                        isLargest = false;
                        break;
                    }
                    // 현재 클러스터가 더 크다면 Iterator를 사용해 기존 클러스터 제거
                    else iterator.remove();
                }
            }
            // 현재 클러스터가 가장 큰 경우에만 리스트에 추가
            if (isLargest&&current!=null) {
                nonOverlappingClusters.add(current);
            }
        }
        return nonOverlappingClusters;
    }

    private boolean isOverlapping(AABB a, AABB b) {
        if (a == null || b == null) {
            return false; // AABB가 null이면 겹치지 않음으로 처리
        }
        return (a.minX <= b.maxX && a.maxX >= b.minX) &&
                (a.minY <= b.maxY && a.maxY >= b.minY) &&
                (a.minZ <= b.maxZ && a.maxZ >= b.minZ);
    }

}