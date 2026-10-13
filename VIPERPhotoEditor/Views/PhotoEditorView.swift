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
                        guard let newItem else {
                            return
                        }

                        guard let data = try? await newItem.loadTransferable(
                            type: Data.self
                        ),
                        let image = UIImage(data: data) else {
                            return
                        }

                        presenter.setImage(image)
                        await presenter.generateFilterPreviews()
                    }
                }


                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PhotoFilter.allCases) { filter in
                            Button {
                                Task {
                                    await presenter.applyFilter(filter)
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Group {
                                        if let preview = presenter.filterPreviews[filter] {
                                            Image(uiImage: preview)
                                                .resizable()
                                                .scaledToFill()
                                        } else {
                                            Rectangle()
                                                .fill(.gray.opacity(0.15))
                                        }
                                    }
                                    .frame(width: 64, height: 64)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(
                                                presenter.selectedFilter == filter
                                                    ? Color.purple
                                                    : Color.clear,
                                                lineWidth: 3
                                            )
                                    }

                                    Text(filter.rawValue)
                                        .font(.caption2)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(presenter.originalImage == nil)
                        }
                    }
                    .padding(.horizontal)
                }


                Spacer()
            }
            .padding()
            .navigationTitle("Photo Editor")
        }
    }
}

