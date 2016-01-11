import Foundation
import CBGPromise

@testable import Movement


class FakeImageRepository: ImageRepository {
    var lastReceivedURL : NSURL?
    var lastRequestPromise : ImagePromise!
    var imageRequested = false

    func fetchImageWithURL(url: NSURL) -> ImageFuture {
        self.lastReceivedURL = url
        self.lastRequestPromise = ImagePromise()
        self.imageRequested = true
        return self.lastRequestPromise.future
    }
}
