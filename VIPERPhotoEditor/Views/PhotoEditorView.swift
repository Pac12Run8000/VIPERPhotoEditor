import SwiftUI
import PhotosUI

struct PhotoEditorView: View {
    
    @State private var showSaveSuccess = false
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""

    @ObservedObject var presenter: PhotoEditorPresenter
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    Text("Photo Editor")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(PhotoEditorColors.navy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    if let image = presenter.editedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .padding(12)
                            .background(
                                PhotoEditorColors.navy.opacity(0.06),
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        PhotoEditorColors.royalBlue.opacity(0.18),
                                        lineWidth: 1
                                    )
                            }
                    } else {
                        ContentUnavailableView(
                            "No Photo Selected",
                            systemImage: "photo",
                            description: Text("Select a photo to begin editing.")
                        )
                    }
                    
                    
                    if presenter.originalImage != nil {
                        VStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Contrast")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Text(presenter.contrast, format: .number.precision(.fractionLength(2)))
                                        .font(.caption)
                                }
                                
                                Slider(
                                    value: $presenter.contrast,
                                    in: 0.5...2.0
                                )
                                .tint(PhotoEditorColors.royalBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Saturation")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Text(presenter.saturation, format: .number.precision(.fractionLength(2)))
                                        .font(.caption)
                                }
                                
                                Slider(
                                    value: $presenter.saturation,
                                    in: 0.0...2.0
                                )
                                .tint(PhotoEditorColors.royalBlue)
                            }
                            Button {
                                presenter.resetImage()
                            } label: {
                                Label("Reset to Original", systemImage: "arrow.counterclockwise")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(PhotoEditorColors.royalBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(16)
                        .background(
                            PhotoEditorColors.brightBlue.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .task(id: [presenter.contrast, presenter.saturation]) {
                            do {
                                try await Task.sleep(for: .milliseconds(150))
                                try Task.checkCancellation()
                                await presenter.updateAdjustments()
                            } catch {
                                // A newer slider value cancelled this request.
                            }
                        }
                        
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
                    
                    if presenter.editedImage != nil {
                        Button {
                            Task {
                                do {
                                    try await presenter.savePhoto()
                                    showSaveSuccess = true
                                } catch {
                                    saveErrorMessage = error.localizedDescription
                                    showSaveError = true
                                }
                            }
                        } label: {
                            Label("Save Photo", systemImage: "square.and.arrow.down")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(
                                    PhotoEditorColors.royalBlue,
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                        }
                    }
                    
                    
                    if presenter.originalImage != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Filters")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundStyle(PhotoEditorColors.navy)
                                .padding(.horizontal, 16)
                            
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
                                                        .strokeBorder(
                                                            presenter.selectedFilter == filter
                                                            ? PhotoEditorColors.royalBlue
                                                            : Color.clear,
                                                            lineWidth: 3
                                                        )
                                                }
                                                .shadow(
                                                    color: presenter.selectedFilter == filter
                                                    ? PhotoEditorColors.royalBlue.opacity(0.25)
                                                    : .clear,
                                                    radius: 5,
                                                    y: 2
                                                )
                                                
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
                    }
                    
                    
                    
                    
                }
                .padding()
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        .alert("Photo Saved", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your edited photo was saved to your photo library.")
        }
        .alert("Unable to Save Photo", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(saveErrorMessage)
        }
    }
}

