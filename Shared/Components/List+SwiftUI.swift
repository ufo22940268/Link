//
//  List+SwiftUI.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/10.
//

import SwiftUI

extension View {
	func paddingRow() -> some View {
		self.ifOS(.macOS) {
			$0.padding()
		}
	}
}
