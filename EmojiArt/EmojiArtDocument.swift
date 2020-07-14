//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by HuangSenhui on 2020/7/9.
//  ViewModel

import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    static let palette: String = "🐶🦆🐞🐙🦑🦒🐩🐑"
    
    //@Published
    private var emojiArt = EmojiArt() {
        willSet {
            objectWillChange.send()
        }
        didSet {
            UserDefaults.standard.set(emojiArt.json, forKey: Self.untitled)
        }
    }
    
    static let untitled = "EmojiArtDocument.untilted"
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { emojiArt.emojis }
    
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: Self.untitled)) ?? EmojiArt()
        fetchImageData()
    }
    
    
    // MARK: - Intent(s)
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(text: emoji, size: Int(size), x: Int(location.x), y: Int(location.y))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundImageURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchImageData()
    }
    
    private func fetchImageData() {
        backgroundImage = nil
        
        if let url = self.emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        if url == self.emojiArt.backgroundURL {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
