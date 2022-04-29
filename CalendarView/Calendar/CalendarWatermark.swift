//
//  CalendarWatermark.swift
//  Gree_Sales system
//
//  Created by 一郎龙 on 2022/3/21.
//

import UIKit

class CalendarWatermark: UIView {
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    var monthStr: String? {
        didSet{
            self.setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        let height: CGFloat = self.frame.size.height

        //获取绘图上下文
        guard let textContext = UIGraphicsGetCurrentContext() else {return}

        //将坐标系系上下翻转
        textContext.textMatrix = CGAffineTransform.identity
        textContext.translateBy(x: 0, y: height+height/6)
        textContext.scaleBy(x: 1, y: -1)

        let textPath = CGMutablePath()
        textPath.addRect(rect)
        textContext.addPath(textPath)
        //设置填充颜色
        textContext.setFillColor(UIColor.white.withAlphaComponent(0).cgColor)
        textContext.drawPath(using: .fill)

        let str = monthStr ?? ""
        //文字样式属性
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        let attrString = NSAttributedString(string: str,
                                            attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 128),
                                                         NSAttributedString.Key.kern: 0,NSAttributedString.Key.foregroundColor: UIColor(hex: "#C9CDD4").alpha(0.3),
                                                         NSAttributedString.Key.paragraphStyle: style])
        let framesetter = CTFramesetterCreateWithAttributedString(attrString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attrString.length),
                                             textPath, nil)
        CTFrameDraw(frame, textContext)
    }
}
