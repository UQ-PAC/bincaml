import XCTest
import SwiftTreeSitter
import TreeSitterBasilir

final class TreeSitterBasilirTests: XCTestCase {
    func testCanLoadGrammar() throws {
        let parser = Parser()
        let language = Language(language: tree_sitter_basilir())
        XCTAssertNoThrow(try parser.setLanguage(language),
                         "Error loading Basil IR grammar")
    }
}
