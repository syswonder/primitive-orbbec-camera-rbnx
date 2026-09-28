#!/usr/bin/env bash
# ROS 2 + system deps the vendored OrbbecSDK_ROS2 driver needs to
# colcon-build in NATIVE mode. Run once per machine (needs sudo):
#   bash scripts/install_deps.sh
#
# Native is the intended mode for this package (direct USB + host ROS graph;
# see robonix docs architecture/multiplatform-deployment.md "适合 native").
# On a minimal /opt/ros/humble (e.g. this Jetson) none of these are present;
# rclcpp/sensor_msgs pull the rcl/rmw core in transitively. Idempotent —
# apt skips already-installed packages.
set -euo pipefail

PKGS=(
  ros-humble-rclcpp
  ros-humble-rclcpp-components
  ros-humble-sensor-msgs
  ros-humble-std-msgs
  ros-humble-std-srvs
  ros-humble-diagnostic-msgs
  ros-humble-statistics-msgs
  ros-humble-image-transport
  ros-humble-image-publisher
  ros-humble-camera-info-manager
  ros-humble-cv-bridge
  ros-humble-diagnostic-updater
  ros-humble-tf2
  ros-humble-tf2-ros
  ros-humble-tf2-eigen
  ros-humble-tf2-msgs
  ros-humble-tf2-sensor-msgs
  ros-humble-backward-ros
  # ros2 CLI + launch stack — main.py spawns `ros2 launch orbbec_camera ...`
  # at runtime; a minimal /opt/ros/humble ships no `ros2` command.
  ros-humble-ros2cli
  ros-humble-ros2launch
  ros-humble-ros2pkg
  ros-humble-ros2run
  ros-humble-launch
  ros-humble-launch-ros
  ros-humble-launch-xml
  ros-humble-launch-yaml
  libdw-dev
  libgflags-dev
  libgoogle-glog-dev
  nlohmann-json3-dev
)

sudo apt-get update
sudo apt-get install -y "${PKGS[@]}"
echo "[orbbec_camera/install_deps] done."
