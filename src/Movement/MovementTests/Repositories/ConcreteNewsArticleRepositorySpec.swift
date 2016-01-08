@testable import Movement
import Quick
import Nimble
import BrightFutures
import Result

private class NewsArticleRepositoryFakeURLProvider: FakeURLProvider {
    override func newsFeedURL() -> NSURL {
        return NSURL(string: "https://example.com/bernese/")!
    }
}

private class FakeNewsArticleDeserializer: NewsArticleDeserializer {
    var lastReceivedJSONDictionary: NSDictionary!
    let returnedNewsArticles = [NewsArticle(title: "fake news", date: NSDate(), body: "fake body", excerpt: "excerpt", imageURL: NSURL(), url: NSURL())]

    func deserializeNewsArticles(jsonDictionary: NSDictionary) -> Array<NewsArticle> {
        self.lastReceivedJSONDictionary = jsonDictionary
        return self.returnedNewsArticles
    }
}

class ConcreteNewsArticleRepositorySpec: QuickSpec {
    override func spec() {
        describe("ConcreteNewsArticleRepository") {
            var subject: ConcreteNewsArticleRepository!
            var jsonClient: FakeJSONClient!
            let urlProvider = NewsArticleRepositoryFakeURLProvider()
            var newsArticleDeserializer: FakeNewsArticleDeserializer!
            var operationQueue: FakeOperationQueue!

            beforeEach {
                jsonClient = FakeJSONClient()
                newsArticleDeserializer = FakeNewsArticleDeserializer()
                operationQueue = FakeOperationQueue()

                subject = ConcreteNewsArticleRepository(
                    urlProvider: urlProvider,
                    jsonClient: jsonClient,
                    newsArticleDeserializer: newsArticleDeserializer,
                    operationQueue: operationQueue
                )
            }

            describe(".fetchNewsArticles") {
                var newsArticlesFuture: Future<Array<NewsArticle>, NSError>!

                beforeEach {
                    newsArticlesFuture = subject.fetchNewsArticles()
                }

                it("makes a single request to the JSON Client with the correct URL, method and parametrs") {
                    expect(jsonClient.promisesByURL.count).to(equal(1))
                    expect(jsonClient.promisesByURL.keys.first).to(equal(NSURL(string: "https://example.com/bernese/")))

                    let expectedHTTPBodyDictionary =
                    [
                        "from": 0, "size": 30,
                        "_source": ["title", "body", "excerpt", "created_at", "url", "image_url"],
                        "query": [
                            "query_string": [
                                "default_field": "article_type",
                                "query": "NOT ExternalLink OR NOT Issues"
                            ]
                        ],
                        "sort": [
                            "created_at": ["order": "desc"]
                        ]
                    ]

                    expect(jsonClient.lastBodyDictionary).to(equal(expectedHTTPBodyDictionary))
                    expect(jsonClient.lastMethod).to(equal("POST"))
                }

                context("when the request to the JSON client succeeds") {
                    let expectedJSONDictionary = NSDictionary();

                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        promise.success(expectedJSONDictionary)
                    }

                    it("passes the json dictionary to the news item deserializer") {
                        expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())

                        expect(newsArticleDeserializer.lastReceivedJSONDictionary).to(beIdenticalTo(expectedJSONDictionary))
                    }

                    it("calls the completion handler with the deserialized value objects on the operation queue") {
                        expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())

                        operationQueue.lastReceivedBlock()
                        let receivedNewsArticles =  newsArticlesFuture.value!
                        expect(receivedNewsArticles.count).to(equal(1))
                        expect(receivedNewsArticles.first!.title).to(equal("fake news"))
                    }
                }

                context("when the request to the JSON client succeeds but does not resolve with a JSON dictioanry") {
                    beforeEach {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!

                        promise.success([1,2,3])
                        expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                    }

                    it("calls the completion handler with an error") {
                        operationQueue.lastReceivedBlock()
                        expect(newsArticlesFuture.error).notTo(beNil())
                    }
                }

                context("when the request to the JSON client fails") {
                    it("forwards the error to the caller on the operation queue") {
                        let promise = jsonClient.promisesByURL[urlProvider.newsFeedURL()]!
                        let expectedError = NSError(domain: "somedomain", code: 666, userInfo: nil)
                        promise.failure(expectedError)

                        expect(operationQueue.lastReceivedBlock).toEventuallyNot(beNil())
                        operationQueue.lastReceivedBlock()
                        expect(newsArticlesFuture.error).to(beIdenticalTo(expectedError))
                    }
                }
            }
        }
    }
}
