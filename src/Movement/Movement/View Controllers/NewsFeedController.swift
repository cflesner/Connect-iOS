import UIKit

class NewsFeedController: UIViewController {
    private let newsItemRepository: NewsItemRepository
    private let imageRepository: ImageRepository
    private let timeIntervalFormatter: TimeIntervalFormatter
    private let newsItemControllerProvider: NewsItemControllerProvider
    private let analyticsService: AnalyticsService
    private let tabBarItemStylist: TabBarItemStylist
    private let theme: Theme

    private var errorLoadingNews = false

    let tableView = UITableView.newAutoLayoutView()
    let loadingIndicatorView = UIActivityIndicatorView.newAutoLayoutView()

    private var newsItems: Array<NewsItem>!

    init(newsItemRepository: NewsItemRepository,
         imageRepository: ImageRepository,
         timeIntervalFormatter: TimeIntervalFormatter,
         newsItemControllerProvider: NewsItemControllerProvider,
         analyticsService: AnalyticsService,
         tabBarItemStylist: TabBarItemStylist,
         theme: Theme ) {
            self.newsItemRepository = newsItemRepository
            self.imageRepository = imageRepository
            self.timeIntervalFormatter = timeIntervalFormatter
            self.newsItemControllerProvider = newsItemControllerProvider
            self.analyticsService = analyticsService
            self.tabBarItemStylist = tabBarItemStylist
            self.theme = theme

            self.newsItems = []

            super.init(nibName: nil, bundle: nil)

            self.tabBarItemStylist.applyThemeToBarBarItem(self.tabBarItem,
                image: UIImage(named: "newsTabBarIconInactive")!,
                selectedImage: UIImage(named: "newsTabBarIcon")!)

            title = NSLocalizedString("NewsFeed_tabBarTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = NSLocalizedString("NewsFeed_navigationTitle", comment: "")

        let backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("NewsFeed_backButtonTitle", comment: ""),
            style: UIBarButtonItemStyle.Plain,
            target: nil, action: nil)

        navigationItem.backBarButtonItem = backBarButtonItem


        view.addSubview(tableView)
        view.addSubview(loadingIndicatorView)

        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsZero
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.hidden = true
        tableView.registerClass(NewsItemTableViewCell.self, forCellReuseIdentifier: "regularCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "errorCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = self.theme.newsFeedBackgroundColor()
        tableView.autoPinEdgesToSuperviewEdges()

        loadingIndicatorView.startAnimating()
        loadingIndicatorView.hidesWhenStopped = true
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Vertical)
        loadingIndicatorView.autoAlignAxisToSuperviewAxis(.Horizontal)
        loadingIndicatorView.color = self.theme.defaultSpinnerColor()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedRowIndexPath, animated: false)
        }

        self.newsItemRepository.fetchNewsItems({ (receivedNewsItems) -> Void in
            self.errorLoadingNews = false
            self.tableView.hidden = false
            self.loadingIndicatorView.stopAnimating()
            self.newsItems = receivedNewsItems
            self.tableView.reloadData()
            }, error: { (error) -> Void in
                self.errorLoadingNews = true
                self.tableView.reloadData()
                self.analyticsService.trackError(error, context: "Failed to load news feed")

                print(error.localizedDescription)
        })
    }
}

// MARK: UITableViewDataSource

extension NewsFeedController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.errorLoadingNews {
            return 1
        }

        if self.newsItems.count == 0 {
            return 0
        }

        return self.newsItems.count
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.errorLoadingNews {
            return self.tableView(tableView, errorCellForRowAtIndexPath: indexPath)
        } else {
            return self.tableView(tableView, newsItemTableViewCellForRowAtIndexPath: indexPath)
        }
    }

    func tableView(tableView: UITableView, errorCellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("errorCell", forIndexPath: indexPath)
        cell.textLabel!.text = NSLocalizedString("NewsFeed_errorText", comment: "")
        cell.textLabel!.font = self.theme.newsFeedTitleFont()
        cell.textLabel!.textColor = self.theme.newsFeedTitleColor()
        return cell
    }

    func tableView(tableView: UITableView, newsItemTableViewCellForRowAtIndexPath indexPath: NSIndexPath) -> NewsItemTableViewCell {
        // swiftlint:disable force_cast
        let cell = tableView.dequeueReusableCellWithIdentifier("regularCell", forIndexPath: indexPath) as! NewsItemTableViewCell
        // swiftlint:enable force_cast
        let newsItem = self.newsItems[indexPath.row]
        cell.titleLabel.text = newsItem.title
        cell.excerptLabel.text = newsItem.excerpt
        cell.dateLabel.text = self.timeIntervalFormatter.abbreviatedHumanDaysSinceDate(newsItem.date)

        self.applyThemeToNewsCell(cell, newsItem: newsItem)

        cell.newsImageView.image = nil

        if newsItem.imageURL == nil {
            cell.newsImageVisible = false
        } else {
            cell.newsImageVisible = true
            imageRepository.fetchImageWithURL(newsItem.imageURL!).then({ (image) -> AnyObject? in
                cell.newsImageView.image = image as? UIImage
                return image
                }) { (error) -> AnyObject? in
                    return error
            }
        }

        return cell
    }

    func applyThemeToNewsCell(cell: NewsItemTableViewCell, newsItem: NewsItem) {
        cell.titleLabel.font = self.theme.newsFeedTitleFont()
        cell.titleLabel.textColor = self.theme.newsFeedTitleColor()
        cell.excerptLabel.font = self.theme.newsFeedExcerptFont()
        cell.excerptLabel.textColor = self.theme.newsFeedExcerptColor()
        cell.dateLabel.font = self.theme.newsFeedDateFont()

        let disclosureColor: UIColor
        if self.timeIntervalFormatter.numberOfDaysSinceDate(newsItem.date) == 0 {
            disclosureColor = self.theme.highlightDisclosureColor()
        } else {
            disclosureColor =  self.theme.defaultDisclosureColor()
        }

        cell.dateLabel.textColor = disclosureColor
        cell.disclosureView.color = disclosureColor
    }
}

// MARK: UITableViewDelegate

extension NewsFeedController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsItem = self.newsItems[indexPath.row]

        self.analyticsService.trackContentViewWithName(newsItem.title, type: .NewsItem, id: newsItem.url.absoluteString)

        let controller = self.newsItemControllerProvider.provideInstanceWithNewsItem(newsItem)

        self.navigationController?.pushViewController(controller, animated: true)
    }
}