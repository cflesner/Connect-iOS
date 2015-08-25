import UIKit


class DefaultTheme : Theme {
    
    // Mark: Tab Bar
    
    func tabBarTintColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func tabBarFont() -> UIFont {
        return UIFont.systemFontOfSize(10)
    }
    
    func tabBarTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    // MARK: Navigation Bar
    
    func navigationBarBackgroundColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func navigationBarFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(15)
    }
    
    func navigationBarTextColor() -> UIColor {
        return UIColor.whiteColor()
    }

    // MARK: News Feed
    
    func newsFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func newsFeedTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(14.0);
    }
    
    func newsFeedDateColor() -> UIColor {
        return self.carnationColor()
    }
    
    func newsFeedDateFont() -> UIFont {
        return UIFont.systemFontOfSize(12.0)
    }
    
    // MARK: issues
    
    func issuesFeedTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(14.0);
    }
    
    func issuesFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    // MARK: Organize
    
    func organizeFeedTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(14.0);
    }
    
    func organizeFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()        
    }
    
    func organizeFeedDateFont() -> UIFont {
        return UIFont.systemFontOfSize(12.0)
    }
    
    func organizeFeedDateColor() -> UIColor {
        return self.carnationColor()
    }
    
    // MARK: Feed header
    
    func feedHeaderBackgroundColor() -> UIColor {
        return self.carnationColor()
    }
    
    func feedHeaderTextColor() -> UIColor {
        return UIColor.whiteColor()
    }
    
    func feedHeaderFont() -> UIFont {
        return UIFont.boldSystemFontOfSize(10)
    }
    
    // MARK: Connect
    
    func connectFeedTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(14.0);
    }
    
    func connectFeedTitleColor() -> UIColor {
        return self.cornflowerBlueColor()
    }
    
    func connectFeedDateFont() -> UIFont {
        return UIFont.systemFontOfSize(12.0)
    }
    
    func connectFeedDateColor() -> UIColor {
        return self.carnationColor()
    }
    
    // MARK: color definitions
    
    func cornflowerBlueColor() -> UIColor {
        return UIColor(rgba: "#147FD7")
    }
    
    func carnationColor() -> UIColor {
        return UIColor(rgba: "#fc625c")
    }
}