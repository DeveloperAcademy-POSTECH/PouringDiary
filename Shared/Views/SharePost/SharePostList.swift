//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import SwiftUI

struct SharePostList: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.created, order: .reverse)])
    private var posts: FetchedResults<SharePost>

    var body: some View {
        NavigationView {
            Text("NOT IMPLEMENTED")
        }
    }
}

struct SharePostList_Previews: PreviewProvider {
    static var previews: some View {
        SharePostList()
    }
}
