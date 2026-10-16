import SwiftUI

@MainActor
final class PhotoEditorPresenter: ObservableObject {

    @Published private(set) var originalImage: UIImage?
    @Published private(set) var editedImage: UIImage?
    @Published private(set) var selectedFilter: PhotoFilter = .original
    @Published private(set) var filterPreviews: [PhotoFilter: UIImage] = [:]
    @Published private(set) var isProcessing = false
    @Published private(set) var errorMessage: String?
    @Published var contrast: Double = 1.0
    @Published var saturation: Double = 1.0

    private let interactor: PhotoEditorInteractor

    init(interactor: PhotoEditorInteractor) {
        self.interactor = interactor
    }

    func setImage(_ image: UIImage) {
        originalImage = image
        editedImage = image
        selectedFilter = .original
        filterPreviews = [:]
        errorMessage = nil
    }

    func applyFilter(_ filter: PhotoFilter) async {
        guard let originalImage else {
            return
        }

        selectedFilter = filter
        isProcessing = true
        errorMessage = nil

        defer {
            isProcessing = false
        }

        do {
            let filteredImage = try await interactor.applyFilter(
                to: originalImage,
                filter: filter
            )

            editedImage = interactor.adjustImage(
                filteredImage,
                contrast: contrast,
                saturation: saturation
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    func generateFilterPreviews() async {
        guard let originalImage else {
            return
        }
        let thumbnail = interactor.createThumbnail(from: originalImage)

        var previews: [PhotoFilter: UIImage] = [:]

        for filter in PhotoFilter.allCases {
            do {
                let preview = try await interactor.applyFilter(
                    to: thumbnail,
                    filter: filter
                )

                previews[filter] = preview
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        filterPreviews = previews
    }
    
    func updateAdjustments() async {
        guard let originalImage else {
            return
        }

        do {
            let filteredImage = try await interactor.applyFilter(
                to: originalImage,
                filter: selectedFilter
            )

            editedImage = interactor.adjustImage(
                filteredImage,
                contrast: contrast,
                saturation: saturation
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

}
