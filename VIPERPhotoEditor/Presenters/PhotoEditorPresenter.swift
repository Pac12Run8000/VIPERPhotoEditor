import SwiftUI

@MainActor
final class PhotoEditorPresenter: ObservableObject {

    @Published private(set) var originalImage: UIImage?
    @Published private(set) var editedImage: UIImage?
    @Published private(set) var selectedFilter: PhotoFilter = .original
    @Published private(set) var filterPreviews: [PhotoFilter: UIImage] = [:]
    @Published private(set) var isProcessing = false
    @Published private(set) var errorMessage: String?

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
            editedImage = try await interactor.applyFilter(
                to: originalImage,
                filter: filter
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    
    func generateFilterPreviews() async {
        guard let originalImage else {
            return
        }

        var previews: [PhotoFilter: UIImage] = [:]

        for filter in PhotoFilter.allCases {
            do {
                let preview = try await interactor.applyFilter(
                    to: originalImage,
                    filter: filter
                )

                previews[filter] = preview
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        filterPreviews = previews
    }

}
