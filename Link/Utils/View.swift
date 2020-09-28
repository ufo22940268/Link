//
//  View.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/25.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import SwiftUI

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

extension View {
    func navigationBarItems<L, C, T>(leading: L, center: C, trailing: T) -> some View where L: View, C: View, T: View {
        navigationBarItems(leading:
            HStack {
                HStack {
                    leading
                }
                .frame(width: 60, alignment: .leading)
                Spacer()
                HStack {
                    center
                }
                .frame(width: 300, alignment: .center)
                Spacer()
                HStack {
                    // Text("asdasd")
                    trailing
                }
                // .background(Color.blue)
                .frame(width: 100, alignment: .trailing)
            }
            // .background(Color.yellow)
            .frame(width: UIScreen.main.bounds.size.width - 32)
        )
    }

    func anyView() -> AnyView {
        return AnyView(self)
    }

    func lowerCase() -> some View {
        if #available(iOS 14.0, *) {
            return self.textCase(.lowercase).anyView()
        } else {
            return anyView()
        }
    }
}

extension Notification {
    static let refreshDomain = Notification.Name("refreshDomain")
    static let reloadHistory = Notification.Name(rawValue: "initHistory")
}

extension Notification.Name {
    static let updateEndPointDetail = Notification.Name("updateEndPointDetail")
}

