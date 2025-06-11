
import SwiftUI

struct URLField: View {
    @Binding var text: String
    var placeholder: String = "https://"
    
    var body: some View {
        URLTextField(text: $text, placeholder: placeholder)
            .frame(maxHeight: 55)
    }
}

struct URLTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: Context) -> UITextField {
        let urlField = UITextField()
        urlField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        urlField.text = text
        urlField.textColor = .black
        urlField.textContentType = .URL
        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        if let descriptor = UIFont.preferredFont(forTextStyle: .body).fontDescriptor.withDesign(.monospaced) {
            urlField.font = UIFont(descriptor: descriptor, size: 0)
        }
        urlField.delegate = context.coordinator
        return urlField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        guard text.isEmpty || text.contains("://") || uiView.isEditing else {
            uiView.text = "https://" + text
            return
        }
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: URLTextField
        @Binding
        var text: String
        
        init(parent: URLTextField, text: Binding<String>) {
            self.parent = parent
            self._text = text
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard !string.clearWhitespace().isEmpty || string.count < range.length else {
                return false
            }
            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            Task { @MainActor [weak self] in
                self?.parent.text = (textField.text ?? "")
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            guard let text = textField.text else {
                return
            }
            let newText = textField.text?.urlString ?? ""
            Task { @MainActor [weak self] in
                if newText != text {
                    self?.parent.text = newText
                }
                textField.text = newText
            }
        }
    }
}

