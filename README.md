# 🌿 Nature Therapy AI Explorer

**AI-powered educational companion app** for children with special needs (autism, ADHD, learning difficulties). Helps children explore nature through interactive activities while learning about plants, animals, and natural objects.

## Features

- 📷 **AI Camera** — Real-time object detection using Core ML + Vision
- 🌳 **Nature Discovery** — Learn about flora and fauna with fun facts
- 🧘 **Therapy Activities** — Breathing exercises, nature drawing, observation challenges
- 🏆 **Progress Tracking** — Badges, discoveries, activity history (SwiftData)
- ♿ **Accessibility** — Voice descriptions, large text, child-friendly UI

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Swift, SwiftUI, MVVM |
| AI | Core ML, Vision Framework |
| Camera | AVFoundation |
| Data | SwiftData |
| Model Training | Roboflow (YOLOv8 → Core ML) |

## Project Structure

```
NatureTherapyAI/
├── App/
│   ├── NatureTherapyAIApp.swift    # SwiftUI App entry + SwiftData container
│   └── Theme.swift                 # Forest-green nature theme & LeafShape
├── Views/
│   ├── HomeView.swift              # Dashboard with stats & navigation
│   ├── CameraView.swift            # Live camera + bounding boxes + info card
│   ├── DiscoveryView.swift         # Nature object encyclopedia
│   ├── TherapyView.swift           # Breathing, Drawing, Observation
│   ├── ProgressView.swift          # Stats, badges, discovered objects
│   ├── SettingsView.swift          # Accessibility, model info
│   └── Components/
│       ├── BoundingBoxOverlay.swift # Detection box drawing
│       ├── BreathingAnimation.swift # Animated breathing circle
│       ├── NatureDrawingCanvas.swift # Touch drawing with nature tools
│       ├── BadgeView.swift         # Achievement badge display
│       └── ActivityCard.swift      # Reusable card component
├── Camera/
│   ├── CameraManager.swift         # AVFoundation capture pipeline
│   ├── CameraPreview.swift         # UIViewRepresentable preview layer
│   └── SimulatorCameraManager.swift # Simulator fallback with generated images
├── AI/
│   ├── ObjectDetector.swift        # Camera frame → detection results
│   ├── VisionProcessor.swift       # VNCoreMLRequest execution
│   └── ModelHandler.swift          # Core ML model loading
├── Models/
│   ├── DetectionResult.swift       # Bounding box + label + confidence
│   ├── NatureObject.swift          # SwiftData entity for discoveries
│   └── ChildProgress.swift         # SwiftData entity for user progress
├── ViewModels/
│   ├── CameraViewModel.swift       # Camera state + detection coordination
│   ├── DiscoveryViewModel.swift    # Discovered objects management
│   ├── TherapyViewModel.swift      # Activity state management
│   ├── ProgressViewModel.swift     # Progress & badge computation
│   └── HomeViewModel.swift         # Dashboard state
├── Services/
│   ├── DetectionService.swift      # Object persistence + badge updates
│   └── ProgressService.swift       # Activity recording + badge logic
└── Resources/
    ├── Assets.xcassets/            # App assets
    ├── NatureDetection.mlmodel/    # Placeholder — replace with trained model
    └── (model will be here)
```

## Training the AI Model with Roboflow

### 1. Create a Roboflow Project

1. Go to [Roboflow](https://roboflow.com) and sign up
2. Create a new **Object Detection** project named "Nature Detection"
3. Set annotation type to **Bounding Box**

### 2. Collect Images

Recommended dataset for Malaysian rainforest ecosystem:

| Category | Objects | Suggested Images |
|----------|---------|-----------------|
| Trees | Mangrove, Rainforest Tree, Palm | 200+ |
| Plants | Leaf, Flower, Fern, Moss, Mushroom | 300+ |
| Animals | Bird, Butterfly, Insect, Lizard, Monkey | 250+ |
| Natural Objects | Rock, River, Cloud, Grass | 150+ |

- Minimum **100 images per class** for decent accuracy
- Use **400+ images per class** for production quality
- Include varied lighting, angles, and backgrounds
- Taman Negeri Rompin is an ideal location for Malaysian rainforest data

### 3. Upload & Annotate

1. Upload images to Roboflow
2. Draw bounding boxes around each object
3. Label with the correct class name
4. Use the Roboflow annotation tools or upload pre-annotated data

### 4. Preprocessing & Augmentation

In Roboflow, apply:

- **Resize**: 640×640 (YOLOv8 default)
- **Auto-Orient**: Strip EXIF
- **Augmentations**:
  - Flip: Horizontal
  - Rotation: ±15°
  - Brightness: ±25%
  - Blur: 2px
  - Noise: 1% random
  - Mosaic: 50% probability

### 5. Train YOLOv8 Model

1. Go to **Generate** in Roboflow
2. Select **YOLOv8** as the model type
3. Choose **YOLOv8n** (nano) for mobile deployment or **YOLOv8s** (small) for better accuracy
4. Set training epochs: **100-200**
5. Start training (may take 1-4 hours depending on dataset size)

### 6. Export to Core ML

1. After training completes, go to **Deploy**
2. Select **Core ML** as the export format
3. Download the `.mlmodel` file
4. Rename to **`NatureDetection.mlmodel`**
5. Move into `NatureTherapyAI/Resources/NatureDetection.mlmodel`

## Adding the Model to Xcode

### Option A: Drag and Drop

1. Open the Xcode project
2. Drag `NatureDetection.mlmodel` into the `Resources` group
3. Check "Copy items if needed"
4. Ensure it's added to the target

### Option B: Via Finder

1. In Finder, copy `NatureDetection.mlmodel`
2. Right-click `NatureTherapyAI/Resources/` in Xcode
3. Select "Add Files to NatureTherapyAI..."
4. Select the model file
5. Click Add

Xcode will automatically compile the `.mlmodel` to `.mlmodelc` during build.

## Running in Xcode

### Simulator (No Camera)

The app automatically detects simulator mode and uses **SimulatorCameraView**:

1. Open the project in Xcode
2. Select an iOS 17+ simulator (iPhone 15 recommended)
3. Press **Cmd+R**
4. The app shows a simulated forest scene
5. Tap **Start Detection** to begin
6. Generated images are processed through the same Vision pipeline
7. Tap detection boxes to see object info
   - The simulator cycles through different scenes (Forest, River, Garden, Wildlife)
   - Each scene generates a unique image with trees, leaves, flowers, and rocks
   - All detection data flows through the real Vision → Core ML pipeline

### Real Device

1. Connect an iPhone with iOS 17+
2. Select the device in Xcode
3. Press **Cmd+R**
4. Grant camera permission when prompted
5. Point the camera at plants, trees, or nature objects
6. Bounding boxes appear with object names and confidence
7. Tap a box to learn more about the object

## Camera Pipeline Architecture

```
AVCaptureSession (Camera)
        │
        ▼
CMSampleBuffer
        │
        ▼
CVPixelBuffer → CIImage
        │
        ▼
VNCoreMLRequest (Vision)
        │
        ▼
VNCoreMLModel (Core ML)
        │
        ▼
[VNRecognizedObjectObservation]
        │
        ▼
[DetectionResult] ← bounding box, label, confidence
        │
        ▼
BoundingBoxOverlay (SwiftUI)
```

This pipeline stays identical whether running on device or in the simulator. The only difference is the image source:
- **Device**: `AVCaptureVideoDataOutputSampleBufferDelegate`
- **Simulator**: `SimulatorImageGenerator` produces `CGImage` → same `VisionProcessor`

## Permissions

The app requires camera access. The permission message is:

> "This app uses camera to identify plants and animals for nature education."

Configured in `Info.plist` under `NSCameraUsageDescription`.

## Design Theme

| Element | Value |
|---------|-------|
| Primary | Forest Green `#2E6B2E` |
| Secondary | Light Green `#8FBD8F` |
| Accent | Sky Blue `#87CFEB` |
| Warmth | Yellow `#F2CC33` |
| Earth | Brown `#8C5926` |
| Background | Soft Calm `#F2F2EB` |

Child-friendly design with:
- Large, rounded buttons
- Emoji-rich interface
- Simple navigation patterns
- VoiceOver support
- High contrast options
- Calm, non-stimulating colors

## Therapy Activities

### 1. Breathing Exercise
- Visual guided breathing with expanding/contracting circle
- 4-2-6 pattern: Inhale (4s) → Hold (2s) → Exhale (6s)
- Calming nature sounds and visual feedback

### 2. Nature Drawing
- Drawing canvas with nature-themed "brushes"
- Colors inspired by nature
- Save drawings to track progress

### 3. Observation Challenge
- Randomized nature observation tasks
- "Find 3 different types of leaves"
- "Find something smooth and something rough"
- Builds attention and categorization skills

## Progress System

| Badge | Requirement |
|-------|-----------|
| 🔍 First Discovery | Discover first object |
| 🌿 Nature Collector | Discover 5 objects |
| 🏆 Expert Explorer | Discover 10 objects |
| 🧘 Calm Mind | Complete 1 breathing exercise |
| 🕊️ Peaceful Soul | Complete 5 breathing exercises |
| 🎨 Little Artist | Complete 1 drawing |
| 👁️ Sharp Eyes | Complete 1 observation challenge |
| ⏰ Nature Lover | 30 minutes exploration |
| 🌟 Dedicated Naturalist | 2 hours exploration |

All progress is persisted using **SwiftData** with automatic badge calculation.

## Troubleshooting

### "ML model not loaded"
- Ensure `NatureDetection.mlmodel` is in Resources
- The app falls back to demo detections so it still works

### Camera not working in simulator
- This is expected — the app automatically uses SimulatorCameraView
- The detection pipeline remains fully functional

### Build errors after adding model
- Clean build folder (Cmd+Shift+K)
- Ensure model is added to the target

### "Missing Info.plist" error
- Ensure Info.plist is in the project settings under Build Settings
- Verify the path in project.yml matches your setup

## License

Educational project for nature therapy and inclusive education.
# Rompin-Trail-Buddy-
