import Foundation
import Quick
import Nimble
import berniesanders

class AboutFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor { return UIColor.orangeColor() }
    override func aboutButtonBackgroundColor() -> UIColor { return UIColor.yellowColor() }
    override func aboutButtonTextColor() -> UIColor { return UIColor.redColor() }
    override func aboutButtonFont() -> UIFont { return UIFont.italicSystemFontOfSize(111) }
    override func aboutBodyTextFont() -> UIFont { return UIFont.italicSystemFontOfSize(222) }
}

class AboutFakeURLProvider: FakeURLProvider {
    override func codersForSandersURL() -> NSURL! {
        return NSURL(string: "http://example.com/reddit/coders")!
    }
    
    override func designersForSandersURL() -> NSURL! {
        return NSURL(string: "http://example.com/reddit/designers")!
    }
}

class AboutControllerSpec : QuickSpec {
    var subject: AboutController!
    var analyticsService: FakeAnalyticsService!
    var urlOpener: FakeURLOpener!
    let urlProvider = AboutFakeURLProvider()
    let theme = AboutFakeTheme()

    override func spec() {
        describe("AboutController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()
                self.urlOpener = FakeURLOpener()
                self.subject = AboutController(
                    analyticsService: self.analyticsService,
                    urlOpener: self.urlOpener,
                    urlProvider: self.urlProvider,
                    theme: self.theme)
            }
            
            it("has the correct title") {
                expect(self.subject.title).to(equal("About"))
            }
            
            context("When the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("uses the news placeholder image") {
                    var placeholderImage = UIImage(named: "newsHeadlinePlaceholder")
                    var expectedImageData = UIImagePNGRepresentation(placeholderImage)
                    var headlineImageData = UIImagePNGRepresentation(self.subject.logoImageView.image)
                    
                    expect(headlineImageData).to(equal(expectedImageData))
                }
                
                it("has a label explaining about the app") {
                    expect(self.subject.bodyTextLabel.text).to(contain("BernieApp is built by a small group of volunteers"))
                }
                
                it("has a label instructing the user to look at reddit") {
                    expect(self.subject.redditLabel.text).to(contain("look into these sub-reddits:"))
                }
                
                it("has a scroll view containing the UI elements") {
                    expect(self.subject.view.subviews.count).to(equal(1))
                    var scrollView = self.subject.view.subviews.first as! UIScrollView
                    
                    expect(scrollView).to(beAnInstanceOf(UIScrollView.self))
                    expect(scrollView.subviews.count).to(equal(1))
                    
                    var containerView = scrollView.subviews.first as! UIView
                    
                    expect(containerView.subviews.count).to(equal(5))
                    
                    var containerViewSubViews = containerView.subviews as! [UIView]
                    let subViews = self.subject.view.subviews as! [UIView]
                    
                    expect(contains(containerViewSubViews, self.subject.logoImageView)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.bodyTextLabel)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.redditLabel)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.codersButton)).to(beTrue())
                    expect(contains(containerViewSubViews, self.subject.designersButton)).to(beTrue())
                }
                
                it("tracks taps on the back button with the analytics service") {
                    self.subject.didMoveToParentViewController(nil)
                    
                    expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on About"))
                    expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                }
                
                it("has a button for the coders for sanders subreddit") {
                    expect(self.subject.codersButton.titleForState(.Normal)).to((equal("/r/codersforsanders")))
                }
                
                describe("tapping on the coders button") {
                    beforeEach {
                        self.subject.codersButton.tap()
                    }
                    
                    it("opens maps with the correct arugments") {
                        expect(self.urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/reddit/coders")))
                    }
                    
                    it("logs that the user tapped the coders button") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'CodersForSanders' on About"))
                        expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    }
                }
                
                it("has a button for the coders for sanders subreddit") {
                    expect(self.subject.codersButton.titleForState(.Normal)).to((equal("/r/designersforsanders")))
                }

                
                describe("tapping on the designers button") {
                    beforeEach {
                        self.subject.designersButton.tap()
                    }
                    
                    it("opens maps with the correct arugments") {
                        expect(self.urlOpener.lastOpenedURL).to(equal(NSURL(string: "http://example.com/reddit/designers")))
                    }
                    
                    it("logs that the user tapped the designers button") {
                        expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'DesignersForSanders' on About"))
                        expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
                    }
                }
                
                it("styles the screen components with the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                    expect(self.subject.bodyTextLabel.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(self.subject.redditLabel.font).to(equal(UIFont.italicSystemFontOfSize(222)))
                    expect(self.subject.codersButton.backgroundColor).to(equal(UIColor.yellowColor()))
                    expect(self.subject.codersButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    expect(self.subject.codersButton.titleColorForState(.Normal)).to(equal(UIColor.redColor()))
                    expect(self.subject.designersButton.backgroundColor).to(equal(UIColor.yellowColor()))
                    expect(self.subject.designersButton.titleLabel!.font).to(equal(UIFont.italicSystemFontOfSize(111)))
                    expect(self.subject.designersButton.titleColorForState(.Normal)).to(equal(UIColor.redColor()))
                }
            }
        }
    }
}
