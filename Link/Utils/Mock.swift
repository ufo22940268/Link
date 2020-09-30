//
//  Mock.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/14.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import CoreData
import Foundation

let testRecordItem = RecordItem(
    duration: 0.3,
    statusCode: 200,
    time: Date(),
    requestHeader: """
    CONNECT bolt.dropbox.com:443 HTTP/1.1
    Host: bolt.dropbox.com
    Proxy-Connection: keep-alive
    """,
    responseHeader: "server:nginx/1.10.2\ndate:Tue, 15 Sep 2020 11:59:29 GMT\ncontent-type:text/plain\ncontent-length:110\nlast-modified:Sun, 16 Aug 2020 23:47:44 GMT\nconnection:close\netag:\"5f39c5a0-6e\"\naccept-ranges:bytes", responseBody: """
    {
      "feeds_url": "https://api.github.com/feeds",
      "followers_url": "https://api.github.com/user/followers"
    }
    """,
    fields: [RecordItem.WatchField(path: "aasd.ccfdfd.ccff", value: "adfa", watchValue: "wwff")]
)

let testScanLogId = "5f5f130360d3d76e96adc738"
let testEndPointId = "5f57428124eeb35312387497"

let testScanLogs: [ScanLog] = (0 ..< 10).reversed().map { i in
    let t = ScanLog(id: "5f5f130360d3d76e96adc738", url: "/a/b", time: Date() - 5 * 60 * TimeInterval(i), duration: TimeInterval((0 ..< 100).randomElement()!), errorCount: i, endPointId: "")
    return t
}

let testScanLogDetails = [
    ScanLogDetail(id: "5f5f130360d3d76e96adc738", time: Date(), duration: 30, errorCount: 2),
    ScanLogDetail(id: "5f5f130360d3d76e96adc738", time: Date(timeIntervalSince1970: 20), duration: 20, errorCount: 10),
]

struct TestData {
    static var context: NSManagedObjectContext {
        getPersistentContainer().viewContext
    }

    static var apiEntities: [ApiEntity] {
        let a = ApiEntity(context: Self.context)
        a.paths = "aa.bnb.cc.wefwef"
        a.value = "CoreData: error: Failed to call designated initializer on NSManagedObject class 'Link.EndPointEntity' CoreData: error: Failed to call designated initializer on NSManagedObject class 'Link.EndPointEntity'"
        a.watch = true
        let a2 = ApiEntity(context: Self.context)
        a2.paths = "wefwef2.wef"
        a2.value = "12322"
        a2.watch = false
        return [a, a2]
    }

    static var apiEntity: ApiEntity {
        apiEntities.first!
    }

    static var responseLog: ResponseLog {
        ResponseLog(header: """
            CONNECT bolt.dropbox.com:443 HTTP/1.1
            Host: bolt.dropbox.com
            Proxy-Connection: keep-alive
        """, body: """
            {
              "feeds_url": "https://api.github.com/feeds",
              "followers_url": "https://api.github.com/user/followers"
            }
        """)
    }
}
