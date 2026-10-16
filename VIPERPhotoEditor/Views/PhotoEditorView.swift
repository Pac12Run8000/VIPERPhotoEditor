import SwiftUI
import PhotosUI

struct PhotoEditorView: View {

    @ObservedObject var presenter: PhotoEditorPresenter
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Photo Editor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(PhotoEditorColors.navy)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                        .font(.headline)
                        .foregroundStyle(PhotoEditorColors.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            PhotoEditorColors.royalBlue,
                            in: RoundedRectangle(cornerRadius: 12)
                        )

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


                if presenter.originalImage != nil {
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
                                                    ? PhotoEditorColors.brightBlue
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
                    .padding(.vertical, 12)
                    .background(
                        PhotoEditorColors.brightBlue.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }



                Spacer()
            }
            .padding()
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

