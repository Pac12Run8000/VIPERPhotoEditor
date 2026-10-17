# VIPER Photo Editor

A native iOS photo-editing application built with **SwiftUI**, **Swift**, and **Core Image**, organized using the **VIPER** architectural pattern. Select a photo, apply a filter, fine-tune contrast and saturation, preview the results, and save the edited image to your Photos library.

## Features

- **Photo selection** — Choose an image using Apple's `PhotosPicker`.
- **Five filter options** — Original, Sepia, Monochrome, Saturated, and Desaturated.
- **Filter previews** — Browse thumbnail previews in a horizontally scrolling strip.
- **Live adjustments** — Control contrast and saturation with sliders.
- **Reset** — Restore the original image and default adjustment values.
- **Save Photo** — Export the edited image to the Photos library, with permission handling and success/error feedback.
- **Responsive editing** — Debounced slider updates reduce redundant processing; a reusable `CIContext` and a combined image-processing pipeline reduce rendering work.
- **Scrollable interface** — A SwiftUI layout with a photo preview, adjustment controls, and filter picker.

## Tech Stack

- Swift
- SwiftUI
- UIKit (`UIImage`)
- Core Image (`CIImage`, `CIFilter`, `CIContext`)
- PhotosUI (`PhotosPicker`)
- PhotoKit (`PHPhotoLibrary`) for saving edited photos
- Swift concurrency (`async`/`await`, `Task`)
- Xcode

## Architecture: VIPER

The project separates responsibilities into the following components:

| Component | File | Responsibility |
| --- | --- | --- |
| **View** | `PhotoEditorView.swift` | Displays the editor and handles user input. |
| **Interactor** | `PhotoEditorInteractor.swift` | Applies image effects, generates thumbnails, and saves photos. |
| **Presenter** | `PhotoEditorPresenter.swift` | Manages observable editing state and coordinates operations. |
| **Entity** | `PhotoEdit.swift` | Defines editing-related data and available filters. |
| **Router** | `PhotoEditorRouter.swift` | Constructs the editor module and injects dependencies. |

The app entry point is `VIPERPhotoEditorApp.swift`.

## Getting Started

1. Clone the repository:

   ```bash
   git clone <YOUR-REPOSITORY-URL>
   ```

2. Open `VIPERPhotoEditor.xcodeproj` in Xcode.
3. Select an iOS Simulator or a compatible iPhone.
4. Build and run the app.

The project's minimum deployment target is **iOS 18.5**.

### Photos Library Permission

To support saving edited photos, the app target must include this Info property:

| Key | Suggested value |
| --- | --- |
| `NSPhotoLibraryAddUsageDescription` | `Save your edited photos to your photo library.` |

The app requests **add-only** Photos access when saving. Photo selection uses the system photo picker.

## How to Use

1. Tap **Select Photo** and choose an image.
2. Adjust **Contrast** and **Saturation** using the sliders.
3. Scroll through the **Filters** strip and choose an effect.
4. Tap **Reset to Original** to remove edits and restore the defaults.
5. Tap **Save Photo** to save the edited image to the Photos library. Grant permission if prompted.

## Image Processing

Core Image handles filter effects and color adjustments. The editor uses a shared `CIContext` within its interactor to avoid repeatedly constructing rendering contexts. Its `processImage` method chains filter and adjustment operations before rendering a final `UIImage`, reducing redundant rendering for slider updates.

Slider changes are debounced to limit unnecessary work during dragging. Performance can vary with image resolution and device hardware.

## Project Status

The editor's photo selection, filters, adjustments, reset, and save flow have been exercised in the iPhone Simulator. Additional automated tests and performance profiling with large images would be valuable next steps.

## Potential Enhancements

- Press-and-hold before/after comparison
- Additional filters and editing controls
- Improved large-image processing and task cancellation
- Unit tests for editing state and image-processing behavior
- Accessibility refinements

## License

No license has been specified for this project. Add a `LICENSE` file if you intend to distribute it under an open-source license.
