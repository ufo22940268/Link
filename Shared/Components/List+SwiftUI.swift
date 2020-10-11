//
//  List+SwiftUI.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/10.
//

import SwiftUI

extension View {
	func paddingMacOS() -> some View {
		self.ifOS(.macOS) {
			$0.padding()
		}
	}

//	func compatible() -> some View where Self: some List {
//		self
//	}
}

#if os(macOS)
typealias GroupedListStyle = DefaultListStyle
#endif

#if os(macOS)
#endif
