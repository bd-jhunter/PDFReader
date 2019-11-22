//
//  ViewController.swift
//  PDFReader
//
//  Created by hunter.liu on 2019/11/22.
//  Copyright © 2019 com.jhunter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var pages: [UIImage] = []
    private var currentPage = 0
    private var loadingCost = ""
    private let queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    private func setup() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tapLoad))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tapNext))
        scrollView.zoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.delegate = self
        scrollView.backgroundColor = .white
    }

    @objc private func tapLoad() {
        queue.async {
            var info = mach_timebase_info(numer: 0, denom: 0)
            mach_timebase_info(&info)
            let numer = UInt64(info.numer)
            let denom = UInt64(info.denom)

            let startTime = mach_absolute_time()
            self.pages.removeAll()
            if let path = Bundle.main.path(forResource: "1", ofType: "pdf") {
                self.pages.append(contentsOf: self.loadPDF(path: path))
            }
            self.currentPage = 0
            let endTime = mach_absolute_time()
            let cost = ((endTime - startTime) * numer) / denom / 1000
            print("\(cost)")
            self.loadingCost = "\(cost / 1000) ms"
            DispatchQueue.main.async {
                self.tapNext()
            }
        }
        navigationItem.title = "Loading..."
    }
    
    @objc private func tapNext() {
        guard currentPage < pages.count else { return }
        imageView.image = pages[currentPage]
        navigationItem.title = "\(currentPage + 1)/\(pages.count), \(loadingCost)"
        currentPage += 1
    }
    
    private func loadPDF(path: String) -> [UIImage] {
        var ret: [UIImage] = []
        if let reader = PDFReader(pdfFilePath: path) {
            ret = reader.unwrapper()
        }
        return ret
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
