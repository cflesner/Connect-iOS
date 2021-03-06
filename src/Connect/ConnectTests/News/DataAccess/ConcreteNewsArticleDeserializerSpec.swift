import Foundation
import Quick
import Nimble

@testable import Connect

class ConcreteNewsArticleDeserializerSpec : QuickSpec {
    override func spec() {
        describe("ConcreteNewsArticleDeserializer") {
            var subject: ConcreteNewsArticleDeserializer!

            beforeEach {
                subject = ConcreteNewsArticleDeserializer()
            }

            it("deserializes the news items correctly with the sanitizer") {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let data = TestUtils.dataFromFixtureFileNamed("news_feed", type: "json")

                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                var newsArticles = subject.deserializeNewsArticles(jsonDictionary)

                expect(newsArticles.count).to(equal(2))
                let newsArticleA = newsArticles[0]
                expect(newsArticleA.title).to(equal("On the Road for Bernie in Iowa"))
                var expectedDate = dateFormatter.dateFromString("09-09-2015")
                expect(newsArticleA.date).to(equal(expectedDate))
                expect(newsArticleA.body).to(equal("Larry Cohen reports from Iowa:\n\nOn a hot Iowa Labor Day weekend, everyone was feeling the Bern!"))
                expect(newsArticleA.excerpt).to(equal("Larry Cohen excerpt"))
                expect(newsArticleA.imageURL).to(equal(NSURL(string: "https://berniesanders.com/wp-content/uploads/2015/09/iowa-600x250.jpg")))
                expect(newsArticleA.url).to(equal(NSURL(string: "https://berniesanders.com/on-the-road-for-bernie-in-iowa/")))

                let newsArticleB = newsArticles[1]
                expect(newsArticleB.title).to(equal("Labor Day 2015: Stand Together and Fight Back"))
                expectedDate = dateFormatter.dateFromString("07-09-2015")
                expect(newsArticleB.date).to(equal(expectedDate))
                expect(newsArticleB.body).to(equal("Labor Day is a time for honoring the working people of this country."))
                expect(newsArticleB.excerpt).to(equal("Labor Day excerpt"))
                expect(newsArticleB.imageURL).to(beNil())
                expect(newsArticleB.url).to(equal(NSURL(string: "https://berniesanders.com/labor-day-2015-stand-together-and-fight-back/")))
            }

            it("converts image urls that are empty strings to nil") {
                let originalData = TestUtils.dataFromFixtureFileNamed("news_feed", type: "json")
                var feedString = String(data: originalData, encoding: NSUTF8StringEncoding)!
                feedString = feedString.stringByReplacingOccurrencesOfString("https://berniesanders.com/wp-content/uploads/2015/09/iowa-600x250.jpg", withString: "")
                let dataWithoutImage = feedString.dataUsingEncoding(NSUTF8StringEncoding)!

                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(dataWithoutImage, options: NSJSONReadingOptions())) as! NSDictionary
                var newsArticles = subject.deserializeNewsArticles(jsonDictionary)
                expect(newsArticles.count).to(equal(2))
                let newsArticleA = newsArticles[0]
                expect(newsArticleA.title).to(equal("On the Road for Bernie in Iowa"))
                expect(newsArticleA.imageURL).to(beNil())
            }

            context("when title, body or url are missing") {
                it("should not explode and ignore stories that lack them") {
                    let data = TestUtils.dataFromFixtureFileNamed("dodgy_news_feed", type: "json")

                    let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as! NSDictionary
                    var newsArticles = subject.deserializeNewsArticles(jsonDictionary)

                    expect(newsArticles.count).to(equal(1))
                    let newsArticleA = newsArticles[0]
                    expect(newsArticleA.title).to(equal("This is good news"))
                }
            }

            context("when there's not enough hits") {
                it("should not explode") {
                    var newsArticles = subject.deserializeNewsArticles([String: AnyObject]())
                    expect(newsArticles.count).to(equal(0))

                    newsArticles = subject.deserializeNewsArticles(["hits": [String: AnyObject]()])
                    expect(newsArticles.count).to(equal(0))

                    newsArticles = subject.deserializeNewsArticles(["hits": [ "hits": [String: AnyObject]()]])
                    expect(newsArticles.count).to(equal(0));
                }
            }
        }
    }
}
