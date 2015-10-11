import UIKit
import Quick
import Nimble
import berniesanders

class SettingsFakeTheme : FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }
    
    override func settingsTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }
    
    override func settingsTitleColor() -> UIColor {
        return UIColor.purpleColor()
    }
    
    override func settingsDonateButtonTextColor() -> UIColor {
        return UIColor.greenColor()
    }
    
    override func settingsDonateButtonFont() -> UIFont {
        return UIFont.systemFontOfSize(222)
    }
    
    override func settingsDonateButtonColor() -> UIColor {
        return UIColor.magentaColor()
    }
}

class FakeSettingsController : UIViewController {
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class SettingsControllerSpec : QuickSpec {
    var subject: SettingsController!
    var analyticsService: FakeAnalyticsService!
    let theme = SettingsFakeTheme()

    let regularController = FakeSettingsController(title: "Regular Controller")
    let donateController = TestUtils.donateController()
    
    let flossController = TestUtils.privacyPolicyController()
    var navigationController: UINavigationController!

    override func spec() {
        describe("SettingsController") {
            beforeEach {
                self.analyticsService = FakeAnalyticsService()

                self.subject = SettingsController(tappableControllers: [
                        self.regularController,
                        self.donateController
                    ],
                    analyticsService: self.analyticsService,
                    theme: self.theme)

                self.navigationController = UINavigationController()
                self.navigationController.pushViewController(self.subject, animated: false)
            }
            
            it("should hide the tab bar when pushed") {
                expect(self.subject.hidesBottomBarWhenPushed).to(beTrue())
            }
            
            it("has the correct navigation item title") {
                expect(self.subject.navigationItem.title).to(equal("Settings"))
            }
            
            it("should set the back bar button item title correctly") {
                expect(self.subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }
            
            it("tracks taps on the back button with the analytics service") {
                self.subject.didMoveToParentViewController(nil)
                
                expect(self.analyticsService.lastCustomEventName).to(equal("Tapped 'Back' on Settings"))
                expect(self.analyticsService.lastCustomEventAttributes).to(beNil())
            }
            
            describe("when the view loads") {
                beforeEach {
                    self.subject.view.layoutSubviews()
                }
                
                it("styles the views according to the theme") {
                    expect(self.subject.view.backgroundColor).to(equal(UIColor.orangeColor()))
                }
                
                it("should have rows in the table") {
                    expect(self.subject.tableView.numberOfSections).to(equal(1))
                    expect(self.subject.tableView.numberOfRowsInSection(0)).to(equal(2))
                }
                
                it("should style the regular rows using the theme") {
                    let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                    
                    expect(cell.textLabel!.textColor).to(equal(UIColor.purpleColor()))
                    expect(cell.textLabel!.font).to(equal(UIFont.systemFontOfSize(123)))
                }
                
                it("should style the donate row using the theme") {
                    let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))! as! DonateTableViewCell


                    expect(cell.messageView.textColor).to(equal(UIColor.purpleColor()))
                    expect(cell.messageView.font).to(equal(UIFont.systemFontOfSize(123)))
                    
                    expect(cell.buttonView.backgroundColor).to(equal(UIColor.magentaColor()))
                    expect(cell.buttonView.font).to(equal(UIFont.systemFontOfSize(222)))
                    expect(cell.buttonView.textColor).to(equal(UIColor.greenColor()))
                }
                
                describe("the table contents") {
                    it("has a regular UITableViewCell row for evey configured 'regular' controller") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Regular Controller"))
                        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
                    }
                    
                    it("has a DonateTableViewCell row for a donate controller") {
                        let cell = self.subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))!
                        expect(cell).to(beAnInstanceOf(DonateTableViewCell.self))
                    }
                    
                    describe("tapping the rows") {
                        it("should push a correctly configured news item view controller onto the nav stack") {
                            let tableView = self.subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                            expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.regularController))
                            
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
                            expect(self.subject.navigationController!.topViewController).to(beIdenticalTo(self.donateController))
                        }
                        
                        it("should log a content view with the analytics service") {
                            let tableView = self.subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                            expect(self.analyticsService.lastContentViewName).to(equal("Regular Controller"))
                            expect(self.analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Settings))
                            expect(self.analyticsService.lastContentViewID).to(equal("Regular Controller"))
                        }
                    }
                }
                
            }
        }
    }
}
