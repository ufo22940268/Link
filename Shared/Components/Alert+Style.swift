//
//  Toolbar+Items.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/12.
//

import SwiftUI

extension View {
	func alertToolbar(onDismiss: @escaping () -> Void) -> some View {
		self.toolbar(content: {
			ToolbarItem(placement: .destructiveAction) {
				Button("完成") {
					onDismiss()
				}
			}
		})
	}

	func alertFrame(minHeight: CGFloat = 500) -> some View {
		self.frame(minWidth: 300, minHeight: minHeight)
	}
}
