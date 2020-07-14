//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by HuangSenhui on 2020/7/9.
//  Model

import Foundation

struct EmojiArt: Codable {
    /// 背景图URL
    var backgroundURL: URL?
    /*①private(set)*/ var emojis: [Emoji] = []
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var size: Int
        /// 坐标
        var x: Int
        var y: Int
        var id: Int// UUID()
        
        // ② 私有化构造函数，emojis无法在addEmoji()方法外设置
        fileprivate init(text: String, size: Int, x: Int, y: Int, id: Int) {
            self.text = text
            self.size = size
            self.x = x
            self.y = y
            self.id = id
        }
    }
    
    // encoder
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    init() { }
    // decoder
    init?(json: Data?) {
        if let js = json, let emojiArt = try? JSONDecoder().decode(EmojiArt.self, from: js) {
            self = emojiArt
        } else {
            return nil
        }
    }
    
    private var uniqueID = 0
    
    mutating func addEmoji(text: String, size: Int, x: Int, y: Int) {
        uniqueID += 1
        emojis.append(Emoji(text: text, size: size, x: x, y: y, id: uniqueID))
    }
}
