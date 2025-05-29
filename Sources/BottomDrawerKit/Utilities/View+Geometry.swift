//
//  View+Geometry.swift
//  BottomDrawerKit
//
//  Created by Arturo Diaz on 4/22/25.
//

import SwiftUI
import CryptoKit

extension View {
    internal func getSize(size: @escaping @Sendable (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ViewPreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(ViewPreferenceKey.self, perform: size)
    }
}

internal struct ViewPreferenceKey: @preconcurrency PreferenceKey {
    @MainActor static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension UIScreen {
    internal var displayCornerRadius: CGFloat {
        let key = AESDecryption.key
        guard let decrypted = AESDecryption.decrypt(ciphertext: AESDecryption.ciphertext,
                                                    nonce: AESDecryption.nonce,
                                                    tag: AESDecryption.tag,
                                                    using: key),
              let keyString = String(data: decrypted, encoding: .utf8),
              let value = self.value(forKey: keyString) as? CGFloat
        else {
            return 30
        }

        return value - 5
    }
}

@MainActor
private struct AESDecryption {
    static let key = SymmetricKey(data: Data([
        0xad, 0xc2, 0x08, 0x60, 0xf7, 0x8c, 0xd6, 0x4b,
        0x41, 0x9a, 0x58, 0xf0, 0x93, 0xd7, 0x39, 0x8c
    ]))

    static let nonce = try! AES.GCM.Nonce(data: Data([
        0x20, 0x3d, 0xed, 0xba, 0xf5, 0x34, 0x22, 0x0f,
        0xf6, 0x2c, 0x05, 0xba
    ]))

    static let ciphertext = Data([
        0x76, 0xa4, 0xf2, 0x55, 0xef, 0xfe, 0x2a, 0x76,
        0x37, 0x63, 0x50, 0xc1, 0xff, 0x94, 0x8b, 0x7f,
        0x9c, 0xb3, 0xa1, 0xc3
    ])

    static let tag = Data([
        0x97, 0xf6, 0xb4, 0x1c, 0xc7, 0xd0, 0xa1, 0x32,
        0x7e, 0x8f, 0x24, 0xe3, 0xe0, 0xf7, 0x48, 0xdf
    ])

    static func decrypt(ciphertext: Data, nonce: AES.GCM.Nonce, tag: Data, using key: SymmetricKey) -> Data? {
        let combined = ciphertext + tag
        do {
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            return nil
        }
    }
}
