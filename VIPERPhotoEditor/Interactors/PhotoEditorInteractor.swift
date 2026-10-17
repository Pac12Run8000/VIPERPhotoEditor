import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos


struct PhotoEditorInteractor {
    
    private let context = CIContext()
    
    func adjustImage(
        _ image: UIImage,
        contrast: Double,
        saturation: Double
    ) -> UIImage {
        guard let inputImage = CIImage(image: image) else {
            return image
        }

        let filter = CIFilter.colorControls()
        filter.inputImage = inputImage
        filter.contrast = Float(contrast)
        filter.saturation = Float(saturation)

        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage,from: outputImage.extent)
        else {
            return image
        }

        return UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
    }
    
    func savePhoto(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)

        guard status == .authorized else {
            throw PhotoSaveError.permissionDenied
        }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    func processImage(
        _ image: UIImage,
        filter: PhotoFilter,
        contrast: Double,
        saturation: Double
    ) throws -> UIImage {

        guard let inputImage = CIImage(image: image)?
            .oriented(CGImagePropertyOrientation(image.imageOrientation))
        else {
            throw PhotoEditorError.invalidImage
        }

        let filteredImage: CIImage

        switch filter {
        case .original:
            filteredImage = inputImage

        case .sepia:
            let effect = CIFilter.sepiaTone()
            effect.inputImage = inputImage
            effect.intensity = 1.0
            filteredImage = effect.outputImage ?? inputImage

        case .monochrome:
            let effect = CIFilter.colorMonochrome()
            effect.inputImage = inputImage
            effect.color = CIColor.gray
            effect.intensity = 1.0
            filteredImage = effect.outputImage ?? inputImage

        case .saturated:
            let effect = CIFilter.colorControls()
            effect.inputImage = inputImage
            effect.saturation = 2.0
            filteredImage = effect.outputImage ?? inputImage

        case .desaturated:
            let effect = CIFilter.colorControls()
            effect.inputImage = inputImage
            effect.saturation = 0.5
            filteredImage = effect.outputImage ?? inputImage
        }

        let adjustments = CIFilter.colorControls()
        adjustments.inputImage = filteredImage
        adjustments.contrast = Float(contrast)
        adjustments.saturation = Float(saturation)

        guard let outputImage = adjustments.outputImage,
              let cgImage = context.createCGImage(
                  outputImage,
                  from: outputImage.extent
              )
        else {
            throw PhotoEditorError.processingFailed
        }

        return UIImage(cgImage: cgImage)
    }
    
    
    
    func createThumbnail(
        from image: UIImage,
        maxDimension: CGFloat = 150
    ) -> UIImage {
        let thumbnailSize = CGSize(
            width: maxDimension,
            height: maxDimension
        )

        let scale = max(
            thumbnailSize.width / image.size.width,
            thumbnailSize.height / image.size.height
        )

        let scaledSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let origin = CGPoint(
            x: (thumbnailSize.width - scaledSize.width) / 2,
            y: (thumbnailSize.height - scaledSize.height) / 2
        )

        let renderer = UIGraphicsImageRenderer(size: thumbnailSize)

        return renderer.image { _ in
            image.draw(
                in: CGRect(
                    origin: origin,
                    size: scaledSize
                )
            )
        }
    }



    func applyFilter(
        to image: UIImage,
        filter: PhotoFilter
    ) async throws -> UIImage {
        let inputImage = CIImage(
            image: image
        )?.oriented(
            CGImagePropertyOrientation(image.imageOrientation)
        )

        guard let inputImage else {
            throw PhotoEditorError.invalidImage
        }

        let outputImage: CIImage

        switch filter {
        case .original:
            outputImage = inputImage

        case .sepia:
            let sepiaFilter = CIFilter.sepiaTone()
            sepiaFilter.inputImage = inputImage
            sepiaFilter.intensity = 1.0

            outputImage = sepiaFilter.outputImage ?? inputImage

        case .monochrome:
            let monochromeFilter = CIFilter.colorMonochrome()
            monochromeFilter.inputImage = inputImage
            monochromeFilter.color = CIColor.gray
            monochromeFilter.intensity = 1.0

            outputImage = monochromeFilter.outputImage ?? inputImage
        case .saturated:
            let saturationFilter = CIFilter.colorControls()
            saturationFilter.inputImage = inputImage
            saturationFilter.saturation = 2.0

            outputImage = saturationFilter.outputImage ?? inputImage
        case .desaturated:
            let desaturationFilter = CIFilter.colorControls()
            desaturationFilter.inputImage = inputImage
            desaturationFilter.saturation = 0.5

            outputImage = desaturationFilter.outputImage ?? inputImage


        }

       

        guard let cgImage = context.createCGImage(
            outputImage,
            from: outputImage.extent
        ) else {
            throw PhotoEditorError.processingFailed
        }

        return UIImage(cgImage: cgImage)
    }
}

enum PhotoEditorError: Error {
    case invalidImage
    case processingFailed
}

enum PhotoSaveError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo library permission was denied."
        }
    }
}



private extension CGImagePropertyOrientation {

    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .down:
            self = .down
        case .left:
            self = .left
        case .right:
            self = .right
        case .upMirrored:
            self = .upMirrored
        case .downMirrored:
            self = .downMirrored
        case .leftMirrored:
            self = .leftMirrored
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
