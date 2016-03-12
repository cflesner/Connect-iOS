import Quick
import Nimble
import CoreLocation

@testable import Connect

class NewEventsControllerSpec: QuickSpec {
    override func spec() {
        describe("NewEventsController") {
            var subject: NewEventsController!
            var interstitialController: UIViewController!
            var resultsController: UIViewController!
            var errorController: UIViewController!
            var nearbyEventsUseCase: MockNearbyEventsUseCase!
            var fetchEventsUseCase: MockFetchEventsUseCase!
            var childControllerBuddy: MockChildControllerBuddy!

            beforeEach {
                interstitialController = UIViewController()
                resultsController = UIViewController()
                errorController = UIViewController()
                nearbyEventsUseCase = MockNearbyEventsUseCase()
                fetchEventsUseCase = MockFetchEventsUseCase()
                childControllerBuddy = MockChildControllerBuddy()

                subject = NewEventsController(
                    interstitialController: interstitialController,
                    resultsController: resultsController,
                    errorController: errorController,
                    nearbyEventsUseCase: nearbyEventsUseCase,
                    fetchEventsUseCase: fetchEventsUseCase,
                    childControllerBuddy: childControllerBuddy
                )
            }

            describe("when the view loads") {
                it("adds the results view as a subview") {
                    subject.view.layoutSubviews()

                    expect(subject.view.subviews).to(contain(subject.resultsView))
                }

                it("initially adds the interstitial controller as a child controller in the results view") {
                    subject.view.layoutSubviews()

                    expect(childControllerBuddy.lastAddedViewController) === interstitialController
                    expect(childControllerBuddy.lastAddedParentViewController) === subject
                    expect(childControllerBuddy.lastAddedContainerView) === subject.resultsView
                }

                it("asks the nearby events use case to fetch events") {
                    subject.view.layoutSubviews()

                    expect(nearbyEventsUseCase.didFetchNearbyEvents) == true
                }
            }

            describe("as a nearby events use case observer") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                context("when the use case finds nearby events") {
                    it("swaps the interstitial controller for the results controller") {
                        let event = TestUtils.eventWithName("nearby event")
                        nearbyEventsUseCase.simulateFindingEvents([event])

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === resultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case finds no nearby events") {
                    it("swaps the interstitial controller for the results controller") {
                        nearbyEventsUseCase.simulateFindingNoEvents()

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === resultsController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }

                context("when the use case encounters an error") {
                    it("swaps the interstitial controller for the error controller") {
                        let error = NearbyEventsUseCaseError.FindingLocationError(.PermissionsError)
                        nearbyEventsUseCase.simulateFailingToFindEvents(error)

                        expect(childControllerBuddy.lastOldSwappedController) === interstitialController
                        expect(childControllerBuddy.lastNewSwappedController) === errorController
                        expect(childControllerBuddy.lastParentSwappedController) === subject
                    }
                }
            }
        }
    }
}

//private class MockCurrentLocationUseCase: CurrentLocationUseCase {
//    var observers = [CurrentLocationUseCaseObserver]()
//
//    private func addObserver(observer: CurrentLocationUseCaseObserver) {
//        observers.append(observer)
//    }
//
//
//    var successHandlers: [(CLLocation) -> ()] = []
//    var errorHandlers: [(CurrentLocationUseCaseError) -> ()] = []
//    var didFetchCurrentLocation = false
//    private func fetchCurrentLocation(successHandler: (CLLocation) -> (), errorHandler: (CurrentLocationUseCaseError) -> ()) {
//        didFetchCurrentLocation = true
//        successHandler.append(successHandler)
//        errorHandlers.append(errorHandlers)
//    }
//
//    private func simulateFoundLocation(location: CLLocation) {
//        for handler in successHandlers {
//            handler(location)
//        }
//        handlers.removeAll()
//    }
//
//    private func simulateFailure() {
//        for handler in errorHandlers {
//            handler(.PermissionsError)
//        }
//        handlers.removeAll()
//    }
//}

private class MockChildControllerBuddy: ChildControllerBuddy {
    var lastOldSwappedController: UIViewController!
    var lastNewSwappedController: UIViewController!
    var lastParentSwappedController: UIViewController!
    var lastCompletionHandler: ChildControllerBuddySwapCompletionHandler!

    func swap(old: UIViewController, new: UIViewController, parent: UIViewController, completionHandler: ChildControllerBuddySwapCompletionHandler) {
        lastOldSwappedController = old
        lastNewSwappedController = new
        lastParentSwappedController = parent
        lastCompletionHandler = completionHandler
    }

    var lastAddedViewController: UIViewController?
    var lastAddedParentViewController: UIViewController?
    var lastAddedContainerView: UIView?
    func add(new: UIViewController, to parent: UIViewController, containIn: UIView) {
        lastAddedViewController = new
        lastAddedParentViewController = parent
        lastAddedContainerView = containIn
    }
}

private class MockFetchEventsUseCase: FetchEventsUseCase {
    var lastFetchedLocation: CLLocation?
    var lastFetchedRadiusMiles: Float?
    private func fetchEventsAroundLocation(location: CLLocation, radiusMiles: Float) {
        lastFetchedLocation = location
        lastFetchedRadiusMiles = radiusMiles
    }
}

private class MockNearbyEventsUseCase: NearbyEventsUseCase {
    var observers = [NearbyEventsUseCaseObserver]()

    func addObserver(observer: NearbyEventsUseCaseObserver) {
        observers.append(observer)
    }

    var didFetchNearbyEvents = false
    func fetchNearbyEvents() {
        didFetchNearbyEvents = true
    }

    func simulateFindingEvents(events: [Event]) {
        for observer in observers {
            observer.nearbyEventsUseCase(self, didFetchEvents: events)
        }
    }

    func simulateFindingNoEvents() {
        for observer in observers {
            observer.nearbyEventsUseCaseFoundNoNearbyEvents(self)
        }
    }

    func simulateFailingToFindEvents(error: NearbyEventsUseCaseError) {
        for observer in observers {
            observer.nearbyEventsUseCase(self, didFailFetchEvents: error)
        }
    }
}
