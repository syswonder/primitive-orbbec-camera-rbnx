#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Build phase: colcon-build the vendored OrbbecSDK_ROS2 packages, then
# run rbnx codegen so atlas_bridge can import atlas_pb2 + lifecycle_pb2.
#
# Vendored at src/OrbbecSDK_ROS2 — orbbec/OrbbecSDK_ROS2 upstream
# (last sync used in /Users/howenliu/lab/grasp/driver/OrbbecSDK_ROS2,
# Dabai DCW SDK shipped under orbbec_camera/SDK/). If anything diverges
# from upstream, drop a *.patch alongside src/ documenting the diff.
#
# Output goes into rbnx-build/{ws/install,codegen}/. start.sh sources
# rbnx-build/ws/install/setup.bash before launching atlas_bridge.
set -euo pipefail
PKG="${RBNX_PACKAGE_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$PKG"
CLEAN="${RBNX_BUILD_CLEAN:-}"

if [[ "$CLEAN" == "1" ]]; then
    echo "[orbbec_camera/build] clean: removing rbnx-build/"
    rm -rf rbnx-build
fi
mkdir -p rbnx-build/ws/src rbnx-build/data

# Symlink the vendored ROS source tree into rbnx-build/ws/src/ so colcon
# picks it up. Symlink (not copy) keeps edits to src/ live without a
# rebuild dance — matches realsense_camera_rbnx's pattern.
ln -snf "$PKG/src/OrbbecSDK_ROS2" "$PKG/rbnx-build/ws/src/OrbbecSDK_ROS2"

ROS_DISTRO="${ROS_DISTRO:-humble}"
# shellcheck disable=SC1091
set +u; source "/opt/ros/${ROS_DISTRO}/setup.bash"; set -u

# Verify the native ROS build deps are present before colcon (robonix docs:
# a native package's build: should validate its prerequisites). A minimal
# /opt/ros install is missing most of these; point the operator at the
# one-shot installer rather than failing deep inside cmake.
_MISSING=""
for _p in rclcpp sensor_msgs std_srvs image_transport camera_info_manager \
          cv_bridge diagnostic_updater tf2_ros tf2_sensor_msgs backward_ros; do
    [ -d "/opt/ros/${ROS_DISTRO}/share/${_p}" ] || _MISSING="${_MISSING} ${_p}"
done
# main.py spawns `ros2 launch orbbec_camera ...` at runtime — the CLI must
# be installed too (a minimal /opt/ros ships none). Check it here so a fresh
# machine fails at build, not at boot.
command -v ros2 >/dev/null 2>&1 || _MISSING="${_MISSING} ros2cli(ros2-command)"
if [ -n "${_MISSING}" ]; then
    echo "[orbbec_camera/build] ERROR: missing ROS deps:${_MISSING}" >&2
    echo "[orbbec_camera/build] run once (needs sudo):" \
         "bash \"$(dirname "$0")/install_deps.sh\"" >&2
    exit 1
fi

echo "[orbbec_camera/build] colcon build (orbbec_camera + msgs + description)"
cd "$PKG/rbnx-build/ws"
# Match the upstream build.sh package selection. orbbec_description
# only ships URDF + meshes (no rclcpp_components_register_node), build
# is fast — keep it for completeness even though the static TFs are
# emitted by piper_description_rbnx in this deploy.
colcon build --symlink-install \
    --packages-select orbbec_camera_msgs orbbec_camera orbbec_description \
    --event-handlers console_direct+ \
    --cmake-args -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release
cd "$PKG"

FLAGS=(--out-dir "$PKG/rbnx-build/codegen")
[[ "$CLEAN" == "1" ]] && FLAGS+=(--clean)
echo "[orbbec_camera/build] rbnx codegen ${FLAGS[*]}"
rbnx codegen -p "$PKG" "${FLAGS[@]}"

touch "$PKG/rbnx-build/.rbnx-built"
echo "[orbbec_camera/build] done."
