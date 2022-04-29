//
//  CalendarView.swift
//  Gree_Sales system
//
//  Created by 一郎龙 on 2022/3/21.
//

import UIKit
import SwiftUI

class CalendarView: UIView {
    
    typealias DoneBlock = (TimeModel)->()
    var doneHandle: DoneBlock!
    
    //当月日期Model
    var modelArr: [TimeModel] = []
    
    //动态调整上下月的时间变量
    var dynamicDate = Date()
    
    //默认选中的日期
    var timeModel: TimeModel = TimeModel()
    
    //时间
    static let range: String = "                      "
    private var timeArr: [String] = ["08:00\(range)10:00",
                                   "10:00\(range)12:00",
                                   "12:00\(range)14:00",
                                   "14:00\(range)16:00",
                                   "16:00\(range)18:00",
                                   "18:00\(range)20:00",
                                   "20:00\(range)22:00"]
    private var selectIndex = 0
    //白色背景底
    private lazy var acView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    //选中条
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(hex: "#409EFF")
        return view
    }()

    private lazy var dateBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("预约日期", for: .normal)
        btn.titleLabel?.font = .pingFangMedium(size: 16)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.setTitleColor(UIColor.black, for: .selected)
        btn.addTarget(self, action: #selector(actionForChooseDate), for: .touchUpInside)
        btn.isSelected = true
        return btn
    }()
    
    private lazy var timeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("预约时间", for: .normal)
        btn.titleLabel?.font = .pingFangMedium(size: 16)
        btn.setTitleColor(UIColor.lightGray, for: .normal)
        btn.setTitleColor(UIColor.black, for: .selected)
        btn.addTarget(self, action: #selector(actionForChooseTime), for: .touchUpInside)
        return btn
    }()
    
    //日历工具条
    private lazy var dateToolView: UIView = {
        let view = UIView()
        return view
    }()
    
    //日历工具条显示当前月份标签
    private lazy var monthLb: UILabel = {
        let lab = UILabel()
        lab.font = .pingFangRegular(size: 14)
        lab.textColor = .black
        lab.text = "2021年03月"
        lab.textAlignment = .center
        return lab
    }()
    
    //日历工具条左箭头
    private lazy var toolLeftBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "日历_左箭头"), for: .normal)
        btn.addTarget(self, action: #selector(actionForLeftEvent), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()
    
    //日历工具条右箭头
    private lazy var toolRightBtn: UIButton =  {
        let btn = UIButton()
        btn.setImage(UIImage.init(named: "日历_右箭头"), for: .normal)
        btn.addTarget(self, action: #selector(actionForRightEvent), for: .touchUpInside)
        return btn
    }()

    //星期X显示条
    private lazy var weeksView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.init(red: 125/255.0, green: 126/255.0, blue: 128/25, alpha:  0.16).cgColor
        view.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 1
        return view
    }()
    
    //滚动视图
    private lazy var scrollView: UIScrollView = {
        let _scrollView = UIScrollView()
        _scrollView.contentSize = CGSize.init(width: ScreenWidth*2, height: _scrollView.frame.size.height)
        _scrollView.bounces = false
        _scrollView.isScrollEnabled = false
        _scrollView.isPagingEnabled = true
        _scrollView.showsVerticalScrollIndicator = false
        _scrollView.showsHorizontalScrollIndicator = false
        return _scrollView
    }()
    
    //月份水印背景
    private lazy var watermarkView: CalendarWatermark = {
        let view = CalendarWatermark()
        view.backgroundColor = .white
        view.isHidden = true  //当前版本隐藏水印
        return view
    }()
    
    //日历展示表
     private lazy var collectionView: UICollectionView = {
         let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
         let collection = UICollectionView(frame: CGRect.init(x: 0, y: 34+40, width: ScreenWidth, height: ScreenHeight*0.57*0.57), collectionViewLayout: layout)
         collection.backgroundColor = .clear
         collection.delegate = self
         collection.dataSource = self
         collection.isPagingEnabled = true
         collection.showsHorizontalScrollIndicator = false
         collection.bounces = false
         collection.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.identifier)
         return collection
    }()
    
    //时间选择器
    private lazy var pickerView: UIPickerView = {
        let picker = UIPickerView.init(frame: CGRect.init(x: ScreenWidth, y: 0, width: ScreenWidth, height: ScreenHeight*0.57*0.57+34+40))
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.alpha = 0
        
        let lastDyaDate = YSDateTool.lastDay()
        let com = YSDateTool.currentDateCom(date: lastDyaDate)
        watermarkView.monthStr = "\(com.month!)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//布局
extension CalendarView {
    func setUI() {
        self.addSubview(acView)
        acView.addSubview(lineView)
        acView.addSubview(dateBtn)
        acView.addSubview(timeBtn)

        dateToolView.addSubview(monthLb)
        dateToolView.addSubview(toolLeftBtn)
        dateToolView.addSubview(toolRightBtn)
        
        acView.addSubview(scrollView)
        scrollView.addSubview(watermarkView)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(pickerView)
        
        //日历顶部按钮布局
        acView.snp.makeConstraints{make in
            make.leading.trailing.bottom.equalTo(0)
            make.height.equalTo(ScreenHeight*0.57)
        }
        
        //顶部选中条
        self.lineViewLayout()
        
        //日期按钮
        dateBtn.snp.makeConstraints{make in
            make.top.equalTo(11)
            make.leading.equalTo(28)
            make.width.equalTo(66)
            make.height.equalTo(22)
        }
        
        //时间按钮
        timeBtn.snp.makeConstraints{make in
            make.top.equalTo(11)
            make.centerX.equalToSuperview()
            make.width.equalTo(66)
            make.height.equalTo(22)
        }
        
        //日历+时间滚动视图
        scrollView.snp.makeConstraints{make in
            make.top.equalTo(dateBtn.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        scrollView.addSubview(dateToolView)
        scrollView.addSubview(weeksView)

        //日历工具条布局
        dateToolView.snp.makeConstraints{make in
            make.top.leading.equalTo(0)
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(40)
        }
        
        toolLeftBtn.snp.makeConstraints{make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
            make.leading.equalTo(16)
        }

        toolRightBtn.snp.makeConstraints{make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
            make.trailing.equalTo(-16)
        }

        monthLb.snp.makeConstraints{make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(20)
        }
        
        //周
        weeksView.snp.makeConstraints{make in
            make.top.equalTo(dateToolView.snp.bottom).offset(4)
            make.leading.equalTo(0)
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(30)
        }

        let arr = ["日","一","二","三","四","五","六"]

        for i in 0 ..< arr.count {
            let width = ScreenWidth/7
            let lab = UILabel()
            lab.text = arr[i]
            lab.textColor = UIColor.init(hex: "#323233")
            lab.font = .pingFangRegular(size: 12)
            lab.textAlignment = .center
            weeksView.addSubview(lab)
            lab.snp.makeConstraints{make in
                make.leading.equalTo(width*CGFloat(i))
                make.centerY.equalToSuperview()
                make.width.equalTo(width)
                make.height.equalTo(20)
            }
        }
        
        //水印
        watermarkView.snp.makeConstraints{make in
            make.top.equalTo(weeksView.snp.bottom).offset(2)
            make.leading.equalTo(0)
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(ScreenHeight*0.57*0.57)
        }

        
        let nextBtn: UIButton = UIButton.init(type: .custom)
        nextBtn.frame = CGRect.init(x: (ScreenWidth-145)/2, y: ScreenHeight*0.57*0.57+8+34+40, width: 145, height: 36)
        nextBtn.titleLabel?.font = .pingFangMedium(size: 14)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.backgroundColor = UIColor.init(hex: "#409EFF")
        nextBtn.setTitle("下一步", for: .normal)
        nextBtn.layer.cornerRadius = 18
        nextBtn.addTarget(self, action: #selector(actionForNext), for: .touchUpInside)
        scrollView.addSubview(nextBtn)
        
        let doneBtn: UIButton = UIButton.init(type: .custom)
        doneBtn.frame = CGRect.init(x: ScreenWidth+(ScreenWidth-145)/2, y: ScreenHeight*0.57*0.57+8+34+40, width: 145, height: 36)
        doneBtn.titleLabel?.font = .pingFangMedium(size: 14)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.backgroundColor = UIColor.init(hex: "#409EFF")
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.layer.cornerRadius = 18
        doneBtn.addTarget(self, action: #selector(actionForDone), for: .touchUpInside)
        scrollView.addSubview(doneBtn)
    }
}

// MARK: - 事件分发
extension CalendarView{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let touchePoint = touch.location(in: self)
        if !acView.frame.contains(touchePoint) {
            self.dismissAlertView()
        }
    }
}

// MARK: -交互事件
extension CalendarView {
    
    @objc func actionForChooseDate(){
        self.lineViewLayout()
        self.scrollDate()
    }
    
    @objc func actionForChooseTime(){
        self.lineViewLayout(leading: 1)
        self.scrollTime()
    }
    
    @objc func actionForLeftEvent(){
        dynamicDate = YSDateTool.lastMonth(date: dynamicDate)
        self.isRefrenshMonth()
    }
    
    @objc func actionForRightEvent(){
        dynamicDate = YSDateTool.nextMonth(date: dynamicDate)
        self.isRefrenshMonth()
    }
    
    @objc func actionForNext(){
        self.lineViewLayout(leading: 1)
        self.scrollTime()
    }
    
    @objc func actionForDone(){
        if doneHandle != nil {
            let str = timeArr[selectIndex]
            let arr = str.components(separatedBy: CalendarView.range)
            timeModel.startTime = arr[0]
            timeModel.endTime = arr[1]
            
            let monthStr = timeModel.month < 10 ? "0\(timeModel.month)" : "\(timeModel.month)"
            let dayStr = timeModel.day < 10 ? "0\(timeModel.day)" : "\(timeModel.day)"
            timeModel.dateStr = "\(timeModel.year)-\(monthStr)-\(dayStr)"
            
            doneHandle(timeModel)
        }
        self.dismissAlertView()
    }
    
    func scrollDate(){
        weeksView.isHidden = false
        dateBtn.isSelected = true
        timeBtn.isSelected = false
        scrollView.setContentOffset(CGPoint.init(x: 0, y: 0), animated: true)
    }
    
    func scrollTime(){
        weeksView.isHidden = true
        dateBtn.isSelected = false
        timeBtn.isSelected = true
        scrollView.setContentOffset(CGPoint.init(x: ScreenWidth, y: 0), animated: true)
    }
    
    func isRefrenshMonth(){
        self.setData(date: dynamicDate)
        let com = YSDateTool.currentDateCom(date: dynamicDate)
        monthLb.text = "\(com.year!)年\(com.month!)月"
        watermarkView.monthStr = "\(com.month!)"
        
        let currentCom = YSDateTool.currentDateCom()
        if (com.year! == currentCom.year!  && com.month! > currentCom.month!) || (com.year! > currentCom.year!){
            toolLeftBtn.isHidden = false
        }else{
            toolLeftBtn.isHidden = true
        }
    }
    
    func lineViewLayout(leading: Int = 0){
        lineView.snp.remakeConstraints{make in
            make.top.equalTo(0)
            if leading == 0 {
                make.leading.equalTo(leading)
            }else{
                make.centerX.equalToSuperview()
            }
            make.width.equalTo(66+56)
            make.height.equalTo(2)
        }
    }
}

extension CalendarView{
    /// 显示弹窗
    public func showAlertView() {
        let str = "\(timeModel.startTime)\(CalendarView.range)\(timeModel.endTime)"
        selectIndex = timeArr.firstIndex(of:str) ?? 0
        self.setData()
        self.setUI()
        pickerView.selectRow(selectIndex, inComponent: 0, animated: false)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    /// 隐藏弹窗
    public func dismissAlertView() {
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self!.alpha = 0
        }, completion: {[weak self] finish in
            self!.removeFromSuperview()
        })
    }
}

// MARK: -数据处理
extension CalendarView{
    func setData(date: Date = Date()){
        modelArr.removeAll()
        let count = YSDateTool.countOfDaysInCurrentMonth(date: date)    //当月天数
        for i in 0..<count{
            let model = self.initializeModel(date: date, day: i+1)
            modelArr.append(model)
        }
        let firstWeekDay = YSDateTool.firstWeekDayInCurrentMonth(date: date)    //当月第一天周几
        
        //头部空缺数据填充
        if firstWeekDay != 7 {
            for _ in 0 ..< firstWeekDay{
                let model = self.initializeModel(date: date, day: 0)
                modelArr.insert(model, at: 0)
            }
        }
        //尾部空缺数据填充
        if modelArr.count < 35{
            for _ in modelArr.count ..< 35{
                let model = self.initializeModel(date: date, day: 0)
                modelArr.append(model)
            }
        }
        
        collectionView.reloadData()
    }
    
    func initializeModel(date: Date, day: Int)->TimeModel{
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year, .month, .day], from: date)
        let model = TimeModel()
        model.year = com.year!
        model.month = com.month!
        model.day = day
        let monthStr = com.month! < 10 ? "0\(model.month)" : "\(model.month)"
        let dayStr = com.day! < 10 ? "0\(model.day)" : "\(model.day)"
        model.dateStr = "\(com.year!)-\(monthStr)-\(dayStr)"
        return model
    }
}


// MARK: - UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
extension CalendarView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 35
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarCell.identifier, for: indexPath) as! CalendarCell
        cell.model = modelArr[indexPath.item]
        cell.selectedModel = timeModel
        return cell
    }

    // 定义每个Cell的大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ScreenWidth/7
        let height = (ScreenHeight*0.57*0.57)/5
        return CGSize(width: width-2, height: height-1)
    }
    
    // 定义每个Section的四边间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 3.5, bottom: 0, right: 0)
    }
    
    // 这个是两行cell之间的间距（上下行cell的间距）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // 两个cell之间的间距（同一行的cell的间距）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = modelArr[indexPath.item]
        let com = YSDateTool.currentDateCom()
        if com.year == model.year && com.month == model.month && model.day < com.day! {
            return
        }
        timeModel.year = model.year
        timeModel.month = model.month
        timeModel.day = model.day
        collectionView.reloadData()
    }
}

// MARK: - PickerViewDelegate
extension CalendarView:UIPickerViewDelegate,UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeArr.count
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return ScreenWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        44
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        //设置分割线
        for view in pickerView.subviews {
            if view.frame.size.height <= 50 {
                view.backgroundColor = .clear
                view.layer.borderWidth = 0.5
                view.layer.borderColor = UIColor.init(hex: "#EBEDF0").cgColor
                break
            }
        }
        
        //设置内容样式
        var label = view as? UILabel
        if label == nil {
            label = UILabel.init()
            label?.frame = CGRect.init(x: 0, y: 0, width:ScreenWidth, height:40)
            if row == selectIndex {
                label?.textColor = UIColor.init(hex: "#409EFF")
            }else{
                label?.textColor = UIColor.init(hex: "#666666")
            }
            label?.textAlignment = .center
            label?.minimumScaleFactor = 0.5
            label?.adjustsFontSizeToFitWidth = true
            label?.font = .pingFangMedium(size: 18)
            label?.text = timeArr[row]
        }
        return label!
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectIndex = row
        pickerView.reloadAllComponents()
    }
    
    
}

