//
//  RequestProfileView.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/30.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI

struct ResponseLog {
    internal init(header: String, body: String) {
        self.header = header
        self.body = body
    }

    internal init(data: Data, response: URLResponse) {
        if !data.isEmpty {
            body = String(data: data, encoding: .utf8) ?? nil
        }
        if let response = response as? HTTPURLResponse {
            header = response.allHeaderFields.map { String(describing: $0.key) + ":" + String(describing: $0.value) }.joined(separator: "\n")
            statusCode = response.statusCode
        }
    }

    internal init(error: URLError) {
        body = error.localizedDescription
    }

    var header: String?
    var body: String?
    var statusCode: Int?
}

struct RequestProfileView: View {
    var log: ResponseLog

    var body: some View {
        List {
            if let header = log.header {
                Section(header: Text("Response Header")) {
                    Text(header).font(.caption)
                }
            }

            if let body = log.body {
                Section(header: Text("Response Body")) {
                    Text(body).font(.caption)
                }
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct RequestProfileView_Previews: PreviewProvider {
    static var previews: some View {
        RequestProfileView(log: TestData.responseLog)
    }
}
