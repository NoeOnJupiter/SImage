//
//  File.swift
//  
//
//  Created by Joe Maghzal on 6/15/22.
//
import SwiftUI
import STools

///SImages: A DownsampledImage is a View that displays an Image in a Downsampled style.
public struct DownsampledImage: View {
    private var oldImage: UNImage?
    private var height: CGFloat?
    private var width: CGFloat?
    private let placeHolder: AnyView?
    private let squared: Bool
    private let resizable: Bool
    private let aspectRatio: (CGFloat?, ContentMode)?
    public var body: some View {
        if let oldImage = oldImage {
            if let width = width, let height = height, let image = oldImage.downsampledImage(maxWidth: width, maxHeight: height) {
                viewForImage(image)
                    .framey(width: image.maxDimensions(width: width, height: height).width, height: image.maxDimensions(width: width, height: height).height, masterWidth: self.width, masterHeight: self.height, master: squared)
            }else if let width = width, let image = oldImage.downsampledImage(width: width) {
                viewForImage(image)
                    .framey(width: width, height: image.fitHeight(for: width), masterWidth: self.width, masterHeight: self.height, master: squared)
            }else if let height = height, let image = oldImage.downsampledImage(height: height) {
                viewForImage(image)
                    .framey(width: image.fitWidth(for: height), height: height, masterWidth: self.width, masterHeight: self.height, master: squared)
            }else {
                placeHolder
                    .frame(width: width ?? width, height: height ?? height)
            }
        }else {
            placeHolder
                .frame(width: width ?? width, height: height ?? height)
        }
    }
}

//MARK: - Public Initializer
public extension DownsampledImage {
///SImages: Initialize a DownsampledImage from a UNImage, or a Binding one.
    init(image: UNImage?) {
        self.oldImage = image
        self.height = nil
        self.width = nil
        self.squared = false
        self.aspectRatio = nil
        self.resizable = false
        self.placeHolder = nil
    }
}

//MARK: - Internal Initializer
internal extension DownsampledImage {
    init(image: UNImage?, height: CGFloat?, width: CGFloat?, squared: Bool, aspectRatio: (CGFloat?, ContentMode)?, resizable: Bool, content: AnyView?) {
        self.oldImage = image
        self.height = height
        self.width = width
        self.squared = squared
        self.aspectRatio = aspectRatio
        self.placeHolder = content
        self.resizable = resizable
    }
}

//MARK: - Private Functions
private extension DownsampledImage {
    @ViewBuilder func viewForImage(_ unImage: UNImage) -> some View {
        Image(unImage: unImage)
            .stateModifier(resizable) { image in
                image
                    .resizable()
            }.stateModifier(aspectRatio != nil) { view in
                view
                    .aspectRatio(aspectRatio?.0, contentMode: aspectRatio!.1)
            }
    }
}

//MARK: - Public Modifiers
public extension DownsampledImage {
///DownsampledImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        DownsampledImage(image: oldImage, height: height, width: width, squared: true, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder)
    }
///DownsampledImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        DownsampledImage(image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: true, content: placeHolder)
    }
///DownsampledImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        DownsampledImage(image: oldImage, height: height, width: width, squared: squared, aspectRatio: (ratio, contentMode), resizable: resizable, content: placeHolder)
    }
///DownsampledImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self  {
        DownsampledImage(image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder)
    }
///DownsampledImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        DownsampledImage(image: oldImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: AnyView(placeholder()))
    }
}
