//
//  SharePostList.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/10.
//

import SwiftUI
import CoreData

struct SharePostList: View {
    @Environment(\.managedObjectContext)
    private var viewContext

    @FetchRequest(sortDescriptors: [])
    private var posts: FetchedResults<SharePost>

    var body: some View {
        NavigationView {
            List {
                ForEach(posts) { post in
                    Text(post.id?.uuidString ?? "")
                }
            }
        }
    }
}

struct SharePostList_Previews: PreviewProvider {
    static var previews: some View {
        SharePostList()
    }
}
