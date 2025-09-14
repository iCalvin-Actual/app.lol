
import SwiftUI

struct EmojiPicker: View {
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        #if canImport(UIKit)
        EmojiTextField(text: $text, placeholder: placeholder)
        #else
        Text(text)
        #endif
    }
}

#if canImport(UIKit)
class UIEmojiTextField: UITextField {
    
    override var textInputContextIdentifier: String? { "" }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        .zero
    }
    
    func setEmoji() {
        _ = self.textInputMode
    }
}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    
    func makeUIView(context: Context) -> UIEmojiTextField {
        let emojiTextField = UIEmojiTextField()
        emojiTextField.placeholder = placeholder
        emojiTextField.text = text
        emojiTextField.textAlignment = .center
        emojiTextField.delegate = context.coordinator
        emojiTextField.font = UIFont.systemFont(ofSize: 55)
        return emojiTextField
    }
    
    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField
        
        init(parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            textField.text = string

            return false
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            Task { @MainActor [weak self] in
                self?.parent.text = textField.text ?? ""
            }
        }
    }
}
#endif
