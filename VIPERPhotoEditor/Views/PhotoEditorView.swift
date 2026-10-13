import SwiftUI
import PhotosUI

struct PhotoEditorView: View {

    @ObservedObject var presenter: PhotoEditorPresenter
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = presenter.editedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 350)
                } else {
                    ContentUnavailableView(
                        "No Photo Selected",
                        systemImage: "photo",
                        description: Text("Select a photo to begin editing.")
                    )
                }
                
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images
                ) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        guard let data = try? await newItem?.loadTransferable(
                            type: Data.self
                        ),
                        let image = UIImage(data: data) else {
                            return
                        }

                        presenter.setImage(image)
                    }
                }

                Picker("Filter", selection: Binding(
                    get: { presenter.selectedFilter },
                    set: { filter in
                        Task {
                            await presenter.applyFilter(filter)
                        }
                    }
                )) {
                    ForEach(PhotoFilter.allCases) { filter in
                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .pickerStyle(.menu)
                .disabled(presenter.originalImage == nil)

                if presenter.isProcessing {
                    ProgressView("Applying Filter...")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Photo Editor")
        }
    }
}

