//
//  InfoRow.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/26.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct InfoRow: View {
	// MARK: Lifecycle

	internal init<S>(label: String, value: S?) where S: LosslessStringConvertible {
		self.label = label
		if let value = value {
			self.value = String(value)
		}
	}

	// MARK: Internal

	var label: String
	var value: String?

	var body: some View {
		HStack {
			Text(label)
			Spacer()
			Text(value ?? "").foregroundColor(.gray)
		}
	}
}

struct InfoRow_Previews: PreviewProvider {
	static var previews: some View {
		List {
			InfoRow(label: "a123123", value: "3")
			InfoRow(label: "a", value: 4)
		}
		.listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
	}
}
