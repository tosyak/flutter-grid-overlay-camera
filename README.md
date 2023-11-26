# Grid Camera App

Simple small and slow app for my friend and orthopeddist doctor to check changes in back posture

This Dart/Flutter project creates a camera application with a grid overlay on display and image file and bubble level feature, enhancing photo composition and alignment. The app is built using the camera, sensors, and image_gallery_saver packages.

## Features
- Custom Camera Interface: Utilizes the device's camera to capture photos.
- Grid Overlay: Adds a customizable grid overlay to the camera view, aiding in photo composition.
- Bubble Level: Integrates an accelerometer-based bubble level to ensure the camera is level when taking photos.
- Image Saving: Captures and saves photos with the grid overlay to the device's gallery.
- Focus Adjustment: Allows users to tap on the screen to set the focus point.

## Usage
- Taking Photos: Use the floating action button to capture photos.
- Focusing: Tap on the desired area of the screen to focus.
- Leveling: The bubble level indicator helps align the camera horizontally.

## Customization
- Grid Size: Adjust the grid size by modifying the _drawGrid method.
- Grid and Level Colors: Customize the colors and opacity of the grid lines and bubble level.

###Note
- This app requires camera and storage permissions on the device.
