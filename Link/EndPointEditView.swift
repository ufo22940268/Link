//
//  EndPointEditView.swift
//  Link
//
//  Created by Frank Cheng on 2020/7/4.
//  Copyright © 2020 Frank Cheng. All rights reserved.
//

import SwiftUI
import Combine

struct EndPointSelection {
    var api: Api
    var watch: Bool
}

struct EndPointEditView: View {
    

    @State var selections: [EndPointSelection] = [EndPointSelection]()
        
    @State var apis: [Api] = [Api]()
    @State var apis2: [Api: Bool] = [Api: Bool]()
    @State private var c : AnyCancellable?
    @State var isChecked: Bool = false
    
    fileprivate func loadData() {
        self.c = ApiHelper().fetch()
            .catch { error in
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \EndPointEditView.apis, on: self)
    }
    
    var body: some View {
        List(0..<apis.count, id: \.self) { (i: Int) in
            Toggle(self.apis[i].paths.last ?? "", isOn: self.$apis[i].watch)
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
 
