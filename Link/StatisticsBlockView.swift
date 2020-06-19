//
//  StatisticsBlockView.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/18.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

enum StatisticsBlockStatus {
    case healthy(count: Int)
    case error(count: Int)
    
    var icon: String {
        switch self {
        case .healthy:
            return "sun.min.fill"
        case .error:
            return "cloud.rain"
        }
    }
    
    var label: String {
        switch self {
        case let .error(count):
            return "\(count)"
        case let .healthy(count):
            return "\(count)"
        }
    }
    
    var bgColor: Color {
        switch self {
        case .healthy:
            return .green
        case .error:
            return .red
        }
    }
}

struct StatisticsBlockView: View {
    var status: StatisticsBlockStatus
    var body: some View {
        return VStack {
            HStack {
                Image(systemName: status.icon).font(.system(size: 30))
                Spacer()
            }
            HStack {
                Spacer()
                Text(status.label).font(.system(.title))
            }
        }
        .padding()
        .background(status.bgColor)
        .cornerRadius(8)
    }
}

struct StatisticsBlockView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsBlockView(status: .healthy(count: 10)).colorScheme(.dark)
    }
}
