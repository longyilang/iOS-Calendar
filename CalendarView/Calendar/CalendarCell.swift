//
//  CalendarCell.swift
//  Gree_Sales system
//
//  Created by 一郎龙 on 2022/3/21.
//

import UIKit



class CalendarCell: UICollectionViewCell {
    
    static var identifier = "UICollectionViewCell"
    
    var model:TimeModel?{
        didSet{
            guard let _model = model else {return}
            if _model.day != 0 {
                titleLab.text = "\(_model.day)"
            }else{
                titleLab.text = ""
            }
            
            let com = YSDateTool.currentDateCom()
            if com.year == _model.year && com.month == _model.month && com.day == _model.day {
                titleLab.textColor = UIColor.init(hex: "#409EFF")
            }else if com.year == _model.year && com.month == _model.month && _model.day < com.day!{
                titleLab.textColor = UIColor.init(hex: "#C8C9CC")
            }else{
                titleLab.textColor = UIColor.init(hex: "#323233")
            }
        }
    }
    
    var selectedModel: TimeModel?{
        didSet{
            guard let _model = selectedModel else{return}
            if _model.year == model?.year && _model.month == model?.month && _model.day == model?.day{
                titleLab.backgroundColor = UIColor.init(hex: "#409EFF")
                titleLab.textColor = UIColor.white
            }else{
                titleLab.backgroundColor = UIColor.clear
            }
        }
    }
    
    var titleLab: UILabel = {
        let lan = UILabel()
        lan.font = .pingFangRegular(size: 16)
        lan.textAlignment = .center
        lan.textColor = UIColor.init(hex: "#323233")
        
        lan.layer.cornerRadius = 4
        lan.layer.masksToBounds = true
        return lan
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints{make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
