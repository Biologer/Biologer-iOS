import SwiftUI
import UIKit

struct FindingEditorImagePicker: UIViewControllerRepresentable {
    let source: FindingEditorPhotoSource
    let onSelect: (FindingEditorPhoto) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.sourceType = availableSourceType
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    private var availableSourceType: UIImagePickerController.SourceType {
        let requestedSource: UIImagePickerController.SourceType = source == .camera
            ? .camera
            : .photoLibrary

        guard UIImagePickerController.isSourceTypeAvailable(requestedSource) else {
            return .photoLibrary
        }
        return requestedSource
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate,
        UIImagePickerControllerDelegate {
        private let parent: FindingEditorImagePicker

        init(parent: FindingEditorImagePicker) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            guard
                let image = info[.originalImage] as? UIImage,
                let imageData = image.jpegData(compressionQuality: 0.9)
            else {
                parent.onCancel()
                return
            }

            let imageName = (info[.imageURL] as? URL)?.lastPathComponent
                ?? "finding-\(UUID().uuidString).jpg"
            parent.onSelect(
                FindingEditorPhoto(
                    name: imageName,
                    imageData: imageData,
                    remoteURL: nil
                )
            )
        }
    }
}
