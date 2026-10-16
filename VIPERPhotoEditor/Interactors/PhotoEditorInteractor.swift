import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct PhotoEditorInteractor {
    
    
    
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

        let context = CIContext()

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
