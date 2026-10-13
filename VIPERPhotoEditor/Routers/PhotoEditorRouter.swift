import SwiftUI

@MainActor
struct PhotoEditorRouter {

    static func createModule() -> some View {
        let interactor = PhotoEditorInteractor()
        let presenter = PhotoEditorPresenter(interactor: interactor)

        return PhotoEditorView(presenter: presenter)
    }
}
