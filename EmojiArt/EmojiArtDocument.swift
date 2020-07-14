//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by HuangSenhui on 2020/7/9.
//  ViewModel

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    
    static let palette: String = "🐶🦆🐞🐙🦑🦒🐩🐑"
    
    @Published private var emojiArt: EmojiArtModel/*() {
        willSet {
            objectWillChange.send()
        }
        didSet {
            UserDefaults.standard.set(emojiArt.json, forKey: Self.untitled)
        }
    }*/
    
    static let untitled = "EmojiArtDocument.untilted"
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    
    
    private var autoSaveCancelable: AnyCancellable?
    
    init() {
        emojiArt = EmojiArtModel(json: UserDefaults.standard.data(forKey: Self.untitled)) ?? EmojiArtModel()
        autoSaveCancelable = $emojiArt.sink { emojiArt in
            print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: Self.untitled)
        }
        fetchImageData()
    }
    
    
    // MARK: - Intent(s)
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(text: emoji, size: Int(size), x: Int(location.x), y: Int(location.y))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundImageURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchImageData()
    }
    
    private var fetchImageCancellAble: AnyCancellable?
    
    private func fetchImageData() {
        backgroundImage = nil
        
        if let url = self.emojiArt.backgroundURL {
            fetchImageCancellAble?.cancel() //
            
            let session = URLSession.shared
            let publiser = session.dataTaskPublisher(for: url)
                .map { data, response in
                    UIImage(data: data)
                }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
            
            fetchImageCancellAble = publiser.assign(to: \EmojiArtDocument.backgroundImage, on: self)
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async {
//                        if url == self.emojiArt.backgroundURL {
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
        }
    }
}

extension EmojiArtModel.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
