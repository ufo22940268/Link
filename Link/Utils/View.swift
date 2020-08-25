//
//  View.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/25.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import CoreData

struct Safe<T: RandomAccessCollection & MutableCollection, C: View>: View {
    typealias BoundElement = Binding<T.Element>
    private let binding: BoundElement
    private let content: (BoundElement) -> C

    init(_ binding: Binding<T>, index: T.Index, @ViewBuilder content: @escaping (BoundElement) -> C) {
        self.content = content
        self.binding = .init(get: { binding.wrappedValue[index] },
                             set: { binding.wrappedValue[index] = $0 })
    }

    var body: some View {
        content(binding)
    }
}
