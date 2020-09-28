//
//  List.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/28.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

import SwiftUI

struct ListHeader: ViewModifier {
    func body(content: Content) -> some View {
        Section(header: content) {
            EmptyView()
        }
    }
}

extension View {
    func asListHeader() -> some View {
        modifier(ListHeader())
    }
}
