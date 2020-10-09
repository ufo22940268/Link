//
//  View+Navigation.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/9.
//

import SwiftUI


extension View {
	func navigationBarItems<L, T>(leading: L, trailing: T) -> some View where L : View, T : View {
		return self
	}
	
	func navigationBarItems<T>(trailing: T) -> some View where T : View {
		return self
	}
	
	func navigationBarItems<L>(leading: L) -> some View where L : View {
		return self
	}
	
	func navigationBarTitle<V>(_ view: V) -> some View where V: View {
		return self
	}
	
	func navigationBarTitle(_ text: String) -> some View {
		return self
	}
}
