//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import Combine

struct EndPointEditView: View {
    
    @State var apis: [Api] = [Api]()
    @State private var c : AnyCancellable?
    
    fileprivate func loadData() {
        self.c = ApiHelper().fetch()
            .tryMap( { $0 })
            .assertNoFailure()
            .receive(on: DispatchQueue.main)
            .assign(to: \EndPointEditView.apis, on: self)
    }
    
    var body: some View {
        List(apis) { (api: Api) in
            Text(api.paths.last ?? "")
        }.onAppear {
            self.loadData()
        }
    }
}

struct EndPointEditView_Previews: PreviewProvider {
    static var previews: some View {
        EndPointEditView()
    }
}
 
