//
//  LoadableView.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/6.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct LoadableView<Content: View>: View {
    var contentView: Content
    var loadableState: LoadableState

    init(loadableState: LoadableState, @ViewBuilder content: () -> Content) {
        contentView = content()
        self.loadableState = loadableState
    }

    var emptyView: some View {
        EmptyView()
    }

    var body: some View {
        switch loadableState {
        case .loading:
            LoadableLoadingView()
        case .finished:
            contentView
        case .empty:
            LoadableEmptyView()
        case .error:
            LoadableFailedView()
        case .pending:
            LoadableEmptyView()
        }
    }
}

struct LoadableView_Previews: PreviewProvider {
    static var previews: some View {
        LoadableView(loadableState: LoadableState.finished) {
            EmptyView()
        }
    }
}
