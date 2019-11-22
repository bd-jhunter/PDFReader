//
//  PDFReader.swift
//  PDFReader
//
//  Created by hunter.liu on 2019/11/22.
//  Copyright © 2019 com.jhunter. All rights reserved.
//

import UIKit

class PDFReader: NSObject {
    private let document: CGPDFDocument
    
    init?(pdfFilePath: String) {
        guard let document = CGPDFDocument(URL(fileURLWithPath: pdfFilePath) as CFURL) else { return nil}
        
        self.document = document
        super.init()
    }
    
    func unwrapper() -> [UIImage] {
        var ret: [UIImage] = []
        let targetSize = UIScreen.main.bounds.size
        
        let pageCount = document.numberOfPages
        for pageIndex in 0..<pageCount {
            if let page: CGPDFPage = document.page(at: pageIndex),
                let image = getPageImage(page: page, estimatedSize: targetSize) {
                ret.append(image)
            }
        }
        
        return ret
    }
    
    private func getPageImage(page: CGPDFPage, estimatedSize: CGSize) -> UIImage? {
        var ret: UIImage?
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
            ret = UIGraphicsGetImageFromCurrentImageContext()
            context.restoreGState()
        }
        UIGraphicsEndImageContext()
        return ret
    }
}
