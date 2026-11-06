//
//  InputSourceCatalogTests.swift
//  KeyflipTests
//

import Foundation
import Testing
@testable import Keyflip

struct InputSourceCatalogTests {
    @Test func resolvesNames() {
        let provider = FakeInputSourceProvider(currentID: InputSource.pinyin.id)
        let catalog = InputSourceCatalog(provider: provider)
        #expect(catalog.currentSourceName == "Pinyin - Simplified")
        #expect(catalog.contains(InputSource.kana.id))
        #expect(!catalog.contains("com.example.removed"))

        provider.currentID = InputSource.kana.id
        catalog.refresh()
        #expect(catalog.currentSourceName == "Hiragana")
    }
}
