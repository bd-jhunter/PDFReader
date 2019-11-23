//
//  PDFReaderViewController.swift
//  PDFReader
//
//  Created by hunter.liu on 2019/11/22.
//  Copyright © 2019 com.jhunter. All rights reserved.
//

import UIKit

class PDFReaderViewController: UITableViewController {
    private var documents: [PDFReader] = []
    private let queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return documents.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard documents.count > 0 else { return 0 }
        return documents[section].pageCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)

        if let cell = cell as? PDFTableViewCell {
            cell.updatePage(page: documents[indexPath.section].getPageImage(pageIndex: indexPath.row, estimatedSize: cell.bounds.size))
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if #available(iOS 11.0, *) {
            return tableView.bounds.height - 64.0 - view.safeAreaInsets.top
        } else {
            return tableView.bounds.height - 64.0 - 64
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UILabel = {
            $0.backgroundColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
            $0.text = "第\(section + 1)个PDF文件"
            return $0
        }(UILabel())
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64.0
    }

    // MARK: - Handlers
    @objc private func tapLoad() {
        queue.async {
            var info = mach_timebase_info(numer: 0, denom: 0)
            mach_timebase_info(&info)
            let numer = UInt64(info.numer)
            let denom = UInt64(info.denom)

            let startTime = mach_absolute_time()
            self.documents.removeAll()
            if let path = Bundle.main.path(forResource: "1", ofType: "pdf") {
                if let reader = self.loadPDF(path: path) {
                    self.documents.append(reader)
                }
            }
            if let path = Bundle.main.path(forResource: "2", ofType: "pdf") {
                if let reader = self.loadPDF(path: path) {
                    self.documents.append(reader)
                }
            }
            let endTime = mach_absolute_time()
            let cost = ((endTime - startTime) * numer) / denom / 1000
            print("\(cost)")
            DispatchQueue.main.async {
                self.navigationItem.title = "Cost: \(cost / 1000) ms"
                self.tableView.reloadData()
            }
        }
        navigationItem.title = "Loading..."
    }
    
    // MARK: - Private methods
    private func setup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(tapLoad))
        tableView.estimatedRowHeight = tableView.bounds.size.height
    }
    
    private func loadPDF(path: String) -> PDFReader? {
        return PDFReader(pdfFilePath: path)
    }
}

class PDFTableViewCell: UITableViewCell {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pdfImageView: UIImageView!
    
    private var page: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func updatePage(page: UIImage?) {
        scrollView.zoomScale = 1.0
        pdfImageView.image = page
    }
    
    private func setup() {
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.delegate = self
        scrollView.backgroundColor = .white
    }
}

extension PDFTableViewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pdfImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = scrollView.bounds.size.width > scrollView.contentSize.width ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = scrollView.bounds.size.height > scrollView.contentSize.height ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        pdfImageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}
