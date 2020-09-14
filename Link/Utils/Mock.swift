//
//  Mock.swift
//  Link
//
//  Created by Frank Cheng on 2020/9/14.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import Foundation

let testRecordItem = RecordItem(duration: 0.3, statusCode: 200, time: Date(), requestHeader: """
CONNECT bolt.dropbox.com:443 HTTP/1.1
Host: bolt.dropbox.com
Proxy-Connection: keep-alive
""", responseHeader: """
CONNECT bolt.dropbox.com:443 HTTP/1.1
Host: bolt.dropbox.com
Proxy-Connection: keep-alive
""", responseBody: """
{
  "feeds_url": "https://api.github.com/feeds",
  "followers_url": "https://api.github.com/user/followers"
}
""")


let testScanLogId = "5f5f130360d3d76e96adc738"
