//
//  View+Directive.swift
//  Link
//
//  Created by Frank Cheng on 2020/10/10.
//

import SwiftUI

enum OperatingSystem {
	case macOS
	case iOS
	case tvOS
	case watchOS

	#if os(macOS)
	static let current = macOS
	#elseif os(iOS)
	static let current = iOS
	#elseif os(tvOS)
	static let current = tvOS
	#elseif os(watchOS)
	static let current = watchOS
	#else
	#error("Unsupported platform")
	#endif
}

extension View {
	/**
	Conditionally apply modifiers depending on the target operating system.

	```
	struct ContentView: View {
		var body: some View {
			Text("Unicorn")
				.font(.system(size: 10))
				.ifOS(.macOS, .tvOS) {
					$0.font(.system(size: 20))
				}
		}
	}
	```
	*/
	@ViewBuilder
	func ifOS<Content: View>(
		_ operatingSystems: OperatingSystem...,
		modifier: @escaping (Self) -> Content
	) -> some View {
		if operatingSystems.contains(OperatingSystem.current) {
			modifier(self)
		} else {
			self
		}
	}
	
	
	// The closure unfortunately has to return `AnyView` as `some` cannot yet be used in return values in closures.
	/**
	Modify the view in a closure. This can be useful when you need to conditionally apply a modifier that is unavailable on certain platforms.

	For example, imagine this code needing to run on macOS too where `View#actionSheet()` is not available:

	```
	struct ContentView: View {
		var body: some View {
			Text("Unicorn")
				.modify {
					#if os(iOS)
					return $0.actionSheet(…).eraseToAnyView()
					#endif

					return nil
				}
		}
	}
	```
	*/
	@ViewBuilder
	func modify(_ modifier: (Self) -> AnyView?) -> some View {
		if let view = modifier(self) {
			view
		} else {
			self
		}
	}
}
