//
//  MultilineTextField.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/29.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct MultilineTextField: UIViewRepresentable {
    var placeholder: String
    @Binding var text: String

    var minHeight: CGFloat
    @Binding var calculatedHeight: CGFloat

    init(placeholder: String = "", text: Binding<String>, minHeight: CGFloat, calculatedHeight: Binding<CGFloat>) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self._calculatedHeight = calculatedHeight
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        

        textView.font = .systemFont(ofSize: 17, weight: .regular)

        // Decrease priority of content resistance, so content would not push external layout set in SwiftUI
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = .clear
        
        textView.keyboardType = .URL
        textView.returnKeyType = .next
        textView.autocapitalizationType = .none
        textView.dataDetectorTypes = .link
        textView.becomeFirstResponder()


        // Set the placeholder
        textView.text = placeholder
//        textView.textColor = UIColor.lightGray

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = self.text

        recalculateHeight(view: textView)
    }

    func recalculateHeight(view: UIView) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if minHeight < newSize.height && $calculatedHeight.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = newSize.height // !! must be called asynchronously
            }
        } else if minHeight >= newSize.height && $calculatedHeight.wrappedValue != minHeight {
            DispatchQueue.main.async {
                self.$calculatedHeight.wrappedValue = self.minHeight // !! must be called asynchronously
            }
        }
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: MultilineTextField

        init(_ uiTextView: MultilineTextField) {
            self.parent = uiTextView
        }

        func textViewDidChange(_ textView: UITextView) {
            // This is needed for multistage text input (eg. Chinese, Japanese)
            if textView.markedTextRange == nil {
                parent.text = textView.text ?? String()
                parent.recalculateHeight(view: textView)
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
    }
}



struct MultilineTextField_Previews: PreviewProvider {
    static var previews: some View {
        MultilineTextField(placeholder: "", text: Binding.constant("adfasd"), minHeight: 140, calculatedHeight: Binding.constant(140))
    }
}
