import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Lightweight 3D vector for dice physics, normals, and Euler angles.
class DiceVec3 {
  final double x;
  final double y;
  final double z;

  const DiceVec3(this.x, this.y, this.z);

  DiceVec3 operator +(DiceVec3 other) =>
      DiceVec3(x + other.x, y + other.y, z + other.z);

  DiceVec3 operator -(DiceVec3 other) =>
      DiceVec3(x - other.x, y - other.y, z - other.z);

  DiceVec3 operator *(double scalar) =>
      DiceVec3(x * scalar, y * scalar, z * scalar);

  double dot(DiceVec3 other) => x * other.x + y * other.y + z * other.z;

  double get length => math.sqrt(x * x + y * y + z * z);

  DiceVec3 normalized() {
    final len = length;
    if (len == 0) return const DiceVec3(0, 0, 0);
    return DiceVec3(x / len, y / len, z / len);
  }

  @override
  String toString() => 'DiceVec3($x, $y, $z)';
}

/// Definition of a single physical face of the 6-sided die.
class DiceFaceDef {
  final int value;
  final DiceVec3 localNormal;
  final DiceVec3 localCenter;

  const DiceFaceDef({
    required this.value,
    required this.localNormal,
    required this.localCenter,
  });
}

/// Metadata for rendering a visible face with depth sorting and lighting.
class VisibleDiceFace {
  final int value;
  final double depthZ;
  final double lightIntensity;
  final Matrix4 transform;

  const VisibleDiceFace({
    required this.value,
    required this.depthZ,
    required this.lightIntensity,
    required this.transform,
  });
}

/// Central source of truth for 3D cube face orientation and coordinate mapping.
class DiceFaceOrientation {
  DiceFaceOrientation._();

  /// Canonical resting tilt giving a pleasant 3D isometric perspective.
  /// Reveals the front face prominently while showing the top and right chamfers.
  static const DiceVec3 restingTilt = DiceVec3(-0.24, 0.28, 0.0);

  /// Normalized ambient light vector coming from the top-left-front.
  static final DiceVec3 lightDirection =
      const DiceVec3(-0.35, -0.65, -0.67).normalized();

  /// Canonical 6-face definitions on a unit cube with half-extent 1.0.
  /// Opposite faces sum to 7:
  /// 1 (Front: z = -1) <-> 6 (Back: z = +1)
  /// 2 (Top: y = -1)   <-> 5 (Bottom: y = +1)
  /// 3 (Right: x = +1) <-> 4 (Left: x = -1)
  static const List<DiceFaceDef> canonicalFaces = [
    DiceFaceDef(
      value: 1,
      localNormal: DiceVec3(0, 0, -1),
      localCenter: DiceVec3(0, 0, -1),
    ),
    DiceFaceDef(
      value: 6,
      localNormal: DiceVec3(0, 0, 1),
      localCenter: DiceVec3(0, 0, 1),
    ),
    DiceFaceDef(
      value: 2,
      localNormal: DiceVec3(0, -1, 0),
      localCenter: DiceVec3(0, -1, 0),
    ),
    DiceFaceDef(
      value: 5,
      localNormal: DiceVec3(0, 1, 0),
      localCenter: DiceVec3(0, 1, 0),
    ),
    DiceFaceDef(
      value: 3,
      localNormal: DiceVec3(1, 0, 0),
      localCenter: DiceVec3(1, 0, 0),
    ),
    DiceFaceDef(
      value: 4,
      localNormal: DiceVec3(-1, 0, 0),
      localCenter: DiceVec3(-1, 0, 0),
    ),
  ];

  /// Base Euler angles (rx, ry, rz) to bring face [value] squarely to front (normal = 0, 0, -1).
  static DiceVec3 getBaseEulerForValue(int value) {
    switch (value) {
      case 1: // Front
        return const DiceVec3(0, 0, 0);
      case 2: // Top rotates down around X
        return const DiceVec3(math.pi / 2, 0, 0);
      case 3: // Right rotates towards front around Y
        return const DiceVec3(0, math.pi / 2, 0);
      case 4: // Left rotates towards front around Y
        return const DiceVec3(0, -math.pi / 2, 0);
      case 5: // Bottom rotates up around X
        return const DiceVec3(-math.pi / 2, 0, 0);
      case 6: // Back rotates to front around Y
        return const DiceVec3(0, math.pi, 0);
      default:
        return const DiceVec3(0, 0, 0);
    }
  }

  /// Target Euler rotation for resting die displaying [value], including 3D perspective tilt.
  static DiceVec3 getRestingEulerForValue(int value) {
    final base = getBaseEulerForValue(value);
    return DiceVec3(
      base.x + restingTilt.x,
      base.y + restingTilt.y,
      base.z + restingTilt.z,
    );
  }

  /// Precomputes the local transformation matrix for a face of size [faceSize].
  static Matrix4 getLocalFaceMatrix(int value, double halfExtent) {
    final m = Matrix4.identity();
    final translation = Matrix4.translationValues(0.0, 0.0, -halfExtent);
    switch (value) {
      case 1: // Front: translated along -Z
        m.multiply(translation);
        break;
      case 6: // Back: rotate around Y by pi, translate along -Z
        m.rotateY(math.pi);
        m.multiply(translation);
        break;
      case 2: // Top: rotate around X by -pi/2, translate along -Z
        m.rotateX(-math.pi / 2);
        m.multiply(translation);
        break;
      case 5: // Bottom: rotate around X by pi/2, translate along -Z
        m.rotateX(math.pi / 2);
        m.multiply(translation);
        break;
      case 3: // Right: rotate around Y by pi/2, translate along -Z
        m.rotateY(math.pi / 2);
        m.multiply(translation);
        break;
      case 4: // Left: rotate around Y by -pi/2, translate along -Z
        m.rotateY(-math.pi / 2);
        m.multiply(translation);
        break;
    }
    return m;
  }

  /// Calculates visible faces, their painter's algorithm depth order, and directional lighting.
  static List<VisibleDiceFace> computeVisibleFaces({
    required DiceVec3 cubeRotation,
    required double halfExtent,
    double perspective = 0.0016,
  }) {
    // Rotation matrix for cube
    final rotMatrix = Matrix4.identity()
      ..rotateX(cubeRotation.x)
      ..rotateY(cubeRotation.y)
      ..rotateZ(cubeRotation.z);

    final s = rotMatrix.storage;
    final List<VisibleDiceFace> visible = [];

    for (final face in canonicalFaces) {
      // Rotate local normal by rotMatrix 3x3
      final nx = face.localNormal.x;
      final ny = face.localNormal.y;
      final nz = face.localNormal.z;

      final worldNormalZ = s[2] * nx + s[6] * ny + s[10] * nz;

      // Back-face culling: camera looks down -Z. Visible if normal points towards camera (z <= 0)
      if (worldNormalZ > 0.0) {
        continue;
      }

      final worldNormalX = s[0] * nx + s[4] * ny + s[8] * nz;
      final worldNormalY = s[1] * nx + s[5] * ny + s[9] * nz;
      final worldNormal = DiceVec3(worldNormalX, worldNormalY, worldNormalZ);

      // World center Z for depth sorting
      final cx = face.localCenter.x * halfExtent;
      final cy = face.localCenter.y * halfExtent;
      final cz = face.localCenter.z * halfExtent;
      final worldCenterZ = s[2] * cx + s[6] * cy + s[10] * cz;

      // Diffuse lighting intensity: how directly it faces light
      final dot = -worldNormal.dot(lightDirection);
      final clampedDot = dot.clamp(0.0, 1.0);
      final lightIntensity = 0.78 + (0.22 * clampedDot);

      // Full face transformation matrix:
      // Perspective * Rotation * Local Face Offset
      final localMatrix = getLocalFaceMatrix(face.value, halfExtent);
      final fullMatrix = Matrix4.identity();
      if (perspective > 0) {
        fullMatrix.setEntry(3, 2, perspective);
      }
      fullMatrix.multiply(rotMatrix);
      fullMatrix.multiply(localMatrix);

      visible.add(VisibleDiceFace(
        value: face.value,
        depthZ: worldCenterZ,
        lightIntensity: lightIntensity,
        transform: fullMatrix,
      ));
    }

    // Sort by depth for painter's algorithm:
    // Larger depthZ is further back in the screen (drawn first),
    // Smaller/more negative depthZ is closer to camera (drawn last on top).
    visible.sort((a, b) => b.depthZ.compareTo(a.depthZ));

    return visible;
  }
}
