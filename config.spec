config:
  # string, default "camera".
  # ROS namespace / topic prefix for all streams.
  camera_name: camera

  # string, default "dabai_dcw.launch.py".
  # Launch file from the vendored OrbbecSDK_ROS2 driver, selected per
  # camera model — e.g. "gemini_330_series.launch.py" for the Gemini
  # 335/336 (330-series) cameras.
  launch_file: dabai_dcw.launch.py

  # bool, default true. HW-align depth to the color frame.
  depth_registration: true

  # bool, default false. Debug RViz viewer; off in headless deploys.
  enable_d2c_viewer: false

  # int, defaults 640 / 480 / 10.
  # Color stream width / height / fps.
  color_width: 640
  color_height: 480
  color_fps: 10

  # string, default "MJPG". Color pixel format.
  color_format: MJPG

  # int, defaults 640 / 400 / 10.
  # Depth stream width / height / fps. 0 disables the depth stream.
  depth_width: 640
  depth_height: 400
  depth_fps: 10

  # string, default "". Pin to a specific device when several are
  # connected.
  serial_number: ""

  # string, default "". Pin to a specific USB port.
  usb_port: ""

  # float, seconds, default 30.0; must be > 0.
  # Max wait for the first RGB frame in on_activate before failing.
  sentinel_timeout_s: 30.0

  # Topic-name overrides (rarely needed; derived from camera_name
  # otherwise):
  # rgb_topic:          /<camera_name>/color/image_raw
  # depth_topic:        /<camera_name>/depth/image_raw
  # camera_info_topic:  /<camera_name>/color/camera_info
