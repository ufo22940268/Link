//
//  DomainData.swift
//  Link
//
//  Created by Frank Cheng on 2020/8/3.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Combine
import SwiftUI

final class DomainData: ObservableObject {
    @Published var domains: [DomainEntity] = []
}


