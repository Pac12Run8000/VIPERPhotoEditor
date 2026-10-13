import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct PhotoEditorInteractor {

    func applyFilter(
        to image: UIImage,
        filter: PhotoFilter
    ) async throws -> UIImage {
        let inputImage = CIImage(image: image)

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
