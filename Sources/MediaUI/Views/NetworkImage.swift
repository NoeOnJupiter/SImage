//
//  File.swift
//  
//
//  Created by Joe Maghzal on 9/29/22.
//

import SwiftUI
import STools

///MediaUI: A NetworkImage is a View that displays an Image from the internet in a Downsampled style.
public struct NetworkImage: View {
    @State private var imageState = ImageState.idle
    @State private var error: String?
    @State private var unImage: UNImage?
    private var imageURL: URL?
    private var height: CGFloat?
    private var width: CGFloat?
    private let placeHolder: AnyView?
    private let squared: Bool
    private let resizable: Bool
    private let aspectRatio: (CGFloat?, ContentMode)?
    private let loading: AnyView?
    private let errorView: ((String?) -> AnyView)?
    public var body: some View {
        content
            .onTask {
                await load()
            }
    }
    var content: some View {
        Group {
            switch imageState {
                case .idle:
                    DownsampledImage(image: unImage, height: height, width: width, squared: squared, aspectRatio: aspectRatio, resizable: resizable, content: placeHolder)
                case .loading:
                    if let loading {
                        loading
                    }else {
                        #if canImport(UIKit)
                        ActivityView()
                        #endif
                    }
                case .error:
                    errorView?(error) ?? (placeHolder ?? AnyView(Text(error ?? "")))
            }
        }
    }
}

//MARK: - Private Functions
private extension NetworkImage {
    func load() async {
        guard unImage == nil else {return}
        imageState = .loading
        guard let imageURL else {
            error = "Invalid Image URL"
            imageState = .error
            return
        }
        if let image = ImageConfigurations.cache.image(for: imageURL) {
            unImage = image
            imageState = .idle
        }else {
            do {
                let data = try await URLSession.shared.data(from: imageURL).0
                unImage = UNImage(data: data)
                imageState = .idle
            }catch {
                self.error = error.localizedDescription
                imageState = .error
            }
        }
    }
}

//MARK: - Public Initializers
public extension NetworkImage {
    ///MediaUI: Initialize a NetworkImage from a String.
    init(url: String?) {
        if let url {
            self.imageURL = URL(string: url)
        }
        self.height = nil
        self.width = nil
        self.squared = false
        self.aspectRatio = nil
        self.resizable = false
        self.placeHolder = nil
        self.loading = nil
        self.errorView = nil
    }
    ///MediaUI: Initialize a NetworkImage from an URL.
    init(url: URL?) {
        self.imageURL = url
        self.height = nil
        self.width = nil
        self.squared = false
        self.aspectRatio = nil
        self.resizable = false
        self.placeHolder = nil
        self.loading = nil
        self.errorView = nil
    }
}

//MARK: - Internal Initializers
internal extension NetworkImage {
    init(imageState: ImageState = ImageState.idle, error: String?, unImage: UNImage?, imageURL: URL?, height: CGFloat?, width: CGFloat?, placeHolder: AnyView?, squared: Bool, resizable: Bool, aspectRatio: (CGFloat?, ContentMode)?, loading: AnyView?, errorView: ((String?) -> AnyView)?) {
        self._imageState = State(wrappedValue: imageState)
        self._error = State(wrappedValue: error)
        self._unImage = State(wrappedValue: unImage)
        self.imageURL = imageURL
        self.height = height
        self.width = width
        self.placeHolder = placeHolder
        self.squared = squared
        self.resizable = resizable
        self.aspectRatio = aspectRatio
        self.loading = loading
        self.errorView = errorView
    }
}

///MARK: - Public Modifiers
public extension NetworkImage {
    ///NetworkImage: Make the Image take the Shape of a square.
    func squaredImage() -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: placeHolder, squared: true, resizable: resizable, aspectRatio: aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Sets the mode by which SwiftUI resizes an Image to fit it's space.
    func isResizable() -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: true, aspectRatio: aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Constrains this View's dimesnions to the specified aspect rario.
    func aspect(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: resizable, aspectRatio: (ratio, contentMode), loading: loading, errorView: errorView)
    }
    ///NetworkImage: Positions this View within an invisible frame with the specified size.
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self  {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: resizable, aspectRatio: aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Adds a placeholder View if no Image can be displayed.
    func placeHolder(@ViewBuilder placeholder: () -> some View) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: AnyView(placeholder()), squared: squared, resizable: resizable, aspectRatio: aspectRatio, loading: loading, errorView: errorView)
    }
    ///NetworkImage: Customize the loading View.
    func onLoading(@ViewBuilder loading: () -> some View) -> Self {
        NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: resizable, aspectRatio: aspectRatio, loading: AnyView(loading()), errorView: errorView)
    }
    func onError(@ViewBuilder errorView: @escaping (String?) -> some View) -> Self {
        let closure: ((String?) -> AnyView) = { erroryy in
            AnyView(errorView(erroryy))
        }
        return NetworkImage(imageState: imageState, error: error, unImage: unImage, imageURL: imageURL, height: height, width: width, placeHolder: placeHolder, squared: squared, resizable: resizable, aspectRatio: aspectRatio, loading: loading, errorView: closure)
    }
}

enum ImageState {
    case idle, loading, error
}