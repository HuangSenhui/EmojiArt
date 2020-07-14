//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by HuangSenhui on 2020/7/9.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var document: EmojiArtDocument
    
    @State private var chosenPalette: String = ""
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.fontSize))
                                .onDrag {
                                    return NSItemProvider(object: emoji as NSString)
                                }
                        }
                    }
                    
                }
                .onAppear {
                    self.chosenPalette = self.document.defaultPalette
                }
            }
            
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .overlay(
                            
                            // OptionImageView(uiImage:)
                            
                            // Group是一个万金油 保证有View输出
                            Group {
                                if let uiImage = self.document.backgroundImage {
                                    Image(uiImage: uiImage)
                                }
                            }
                            .scaleEffect(zoomScale)
                            .offset(self.panOffset)
                            
                        )
                        .foregroundColor(.yellow)
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    
                    // emoji在显示背景图之后再显示
                    // spinning modifier
                    
                    
                    // TODO: emoji 没有动画
                    // 叠加文字
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            //                            .font(self.font(for: emoji))
                            .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
                .clipped()
                .gesture(self.panGuestrue())
                .gesture(self.zoomGestrue())
                .edgesIgnoringSafeArea([.horizontal,.bottom])
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
                .onDrop(of: ["public.image","public.text"], isTargeted: nil) { (provider, location) -> Bool in
                    var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: provider, at: location)
                }
            }
        }
    }
    
    // 捏合手势
    @State private var steadyZoomScale: CGFloat = 1.0
    @GestureState private var gestrueZoomScale: CGFloat = 1.0
    
    private var zoomScale: CGFloat {
        steadyZoomScale * gestrueZoomScale
    }

    // 平移手势
    @State private var steadyPanOffset: CGSize = .zero
    @GestureState private var gestruePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyPanOffset + gestruePanOffset) * zoomScale
    }
    
    // TODO: EmogiArtExtension
    private func panGuestrue() -> some Gesture {
        DragGesture()
            .updating($gestruePanOffset) { (one, two, three) in
                two = one.translation / self.zoomScale
            }
            .onEnded { finalGestureValue in
                self.steadyPanOffset = self.steadyPanOffset + (finalGestureValue.translation / self.zoomScale)
            }
    }
    
    
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGestrue() -> some Gesture {
        // 捏合手势
        MagnificationGesture()
            .updating($gestrueZoomScale) { one,two,three in
                two = one
            }
            .onEnded { finaleGesture in
                self.steadyZoomScale *= finaleGesture
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let img = image, size.width > 0 {
            let HZoom = size.width / img.size.width
            let VZoom = size.height / img.size.height
            self.steadyPanOffset = .zero
            self.steadyZoomScale = min(HZoom, VZoom)
        }
    }
    
    
    
    //    private func font(for emoji: EmojiArt.Emoji) -> Font {
    //        Font.system(size: emoji.fontSize * zoomScale)
    //    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.setBackgroundImageURL(url)
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.fontSize)
            }
        }
        return found
    }
    
    private let fontSize: CGFloat = 40
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}


// 能运行，但做法不对，应该使用Key Path
//extension String: Identifiable {
//    public var id: String { return self }
//}
