//
//  PDFReader.swift
//  PDFReader
//
//  Created by hunter.liu on 2019/11/22.
//  Copyright © 2019 com.jhunter. All rights reserved.
//

import UIKit

private class PDFPage: NSObject {
    private let page: CGPDFPage
    private var image: UIImage?
    
    init(page: CGPDFPage) {
        self.page = page
        super.init()
    }

    func getPageImage(estimatedSize: CGSize) -> UIImage? {
        guard image == nil else { return image }
        let rect = page.getBoxRect(CGPDFBox.mediaBox)
        let scale: CGFloat = min(estimatedSize.width/rect.size.width , estimatedSize.height/rect.size.height)
        let targetSize = CGSize(width: scale * rect.size.width, height: scale * rect.size.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 4.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.saveGState()
            context.translateBy(x: 0.0, y: targetSize.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.scaleBy(x: scale, y: scale)
            context.drawPDFPage(page)
            image = UIGraphicsGetImageFromCurrentImageContext()
            context.restoreGState()
        }
        UIGraphicsEndImageContext()
        return image
    }
}

class PDFReader: NSObject {
    var pageCount: Int { return pages.count }
    private var pages: [PDFPage] = []
    
    init?(pdfFilePath: String) {
        super.init()
        self.pages = read(pdfFilePath: pdfFilePath)
    }
    
    func getPageImage(pageIndex: Int, estimatedSize: CGSize) -> UIImage? {
        guard pageCount > pageIndex else { return nil }
        return pages[pageIndex].getPageImage(estimatedSize: estimatedSize)
    }
    
    private func read(pdfFilePath: String) -> [PDFPage] {
        var ret: [PDFPage] = []
        guard let document = CGPDFDocument(URL(fileURLWithPath: pdfFilePath) as CFURL) else { return ret}
        let pageCount = document.numberOfPages
        for pageIndex in 0..<pageCount {
            if let page: CGPDFPage = document.page(at: pageIndex) {
                ret.append(PDFPage(page: page))
            }
        }
        
        return ret
    }
}
