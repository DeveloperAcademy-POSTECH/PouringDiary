//
//  SharedPost.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/07/29.
//

import CoreData

extension SharePost {
    struct Input {
        var image: Data
        var thumbnail: Data
        var diary: Diary
        var content: String
    }
    static func register(input: Input, context: NSManagedObjectContext) async throws -> SharePost {
        do {
            let post = SharePost(context: context)
            let source = try await ImageData.register(data: input.image, context: context)
            try await context.perform(schedule: .immediate) {
                post.id = UUID()
                post.created = Date()
                post.content = input.content
                post.thumbnail = input.thumbnail
                post.image = source
                try context.save()
            }
            return post
        } catch {
            throw error
        }
    }
}
