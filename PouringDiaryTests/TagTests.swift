//
//  TagTests.swift
//  PouringDiary (iOS)
//
//  Created by devisaac on 2022/08/03.
//

import XCTest
import CoreData
@testable import PouringDiary

class TagTests: XCTestCase {

    private var controller: PersistenceController!

    override func setUpWithError() throws {
        controller = PersistenceController(inMemory: true)
    }

    override func tearDownWithError() throws {
        controller = PersistenceController(inMemory: true)
    }

    private func createBulk(count: Int) async -> [Tag] {
        var result: [Tag] = []
        for index in 0..<count {
            let tag = try? await Tag.register(
                input: .init(
                    content: "TAG+\(index)",
                    color: .init(rawValue: index % Tag.Color.allCases.count)!
                ),
                context: controller.container.viewContext
            )
            result.append(tag!)
        }
        return result
    }

    // MARK: Tag 생성
    func testTagCanRegister() async throws {
        let context = controller.container.viewContext
        let newTag = try? await Tag.register(
            input: .init(content: "에티오피아", color: .tag1),
            context: context
        )
        XCTAssert(newTag != nil, "fetch must be run without error")
        XCTAssert(newTag!.content == "에티오피아", "Title must be generate")
        XCTAssert(newTag!.color == Tag.Color.tag1.rawValue, "Color must be generate")
    }

    // MARK: Tag 삭제
    func testTagCanDelete() async throws {
        let context = controller.container.viewContext
        let bulk = await createBulk(count: 5)
        let beforeCount = try context.count(for: Tag.fetchRequest())
        XCTAssert(beforeCount == 5, "Bulk must be done")
        let deletion = bulk.first!
        await Tag.delete(tags: [deletion], context: context)
        let afterCount = try context.count(for: Tag.fetchRequest())
        XCTAssert(afterCount == 4, "delete must be done without error")

    }
}
