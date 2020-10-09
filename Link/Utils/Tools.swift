//
//  Tools.swift
//  Link
//
//  Created by Frank Cheng on 2020/6/20.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import Foundation
import UIKit

func getPersistentContainer() -> NSPersistentContainer {
	return PersistenceController.shared.container
}
