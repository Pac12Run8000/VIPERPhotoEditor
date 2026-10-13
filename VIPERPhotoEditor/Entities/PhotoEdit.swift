import Foundation

struct PhotoEdit {
    var filter: PhotoFilter = .original
    var text: String = ""
}

enum PhotoFilter: String, CaseIterable, Identifiable {
    case original = "Original"
    case sepia = "Sepia"
    case monochrome = "Monochrome"
    case saturated = "Saturated"
    case desaturated = "Desaturated"

    var id: String {
        return rawValue
    }
}
