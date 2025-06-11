
import SwiftUI

struct PathField: View {
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        PathTextField(text: $text, placeholder: placeholder)
            .frame(maxHeight: 55)
    }
}

struct PathTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    
    func makeUIView(context: Context) -> UITextField {
        let pathField = UITextField()
        pathField.attributedPlaceholder = NSAttributedString(string: "/" + placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        pathField.text = text
        pathField.textColor = .black
        pathField.autocapitalizationType = .none
        pathField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        if let descriptor = UIFont.preferredFont(forTextStyle: .title2).fontDescriptor.withDesign(.serif)?.withSymbolicTraits(.traitBold) {
            pathField.font = UIFont(descriptor: descriptor, size: 0)
        }
        pathField.delegate = context.coordinator
        return pathField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text.count == 0 ? text : "/" + text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PathTextField
        
        init(parent: PathTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard !range.contains(0) else {
                return false
            }
            guard !string.clearWhitespace().isEmpty || string.count < range.length else {
                return false
            }

            return true
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            Task { @MainActor [weak self] in
                self?.parent.text = (textField.text ?? "").replacingOccurrences(of: "/", with: "")
            }
        }
    }
}

