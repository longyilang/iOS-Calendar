//
//  ViewController.swift
//  CalendarView
//
//  Created by 一郎龙 on 2022/3/23.
//

import UIKit

import RxSwift

import RxCocoa

class ViewController: UIViewController {

    let bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightBtn = UIButton()
        rightBtn.frame = CGRect.init(x: ScreenWidth-100, y: 44, width: 80, height: 30)
        rightBtn.setTitle("日历选择", for: .normal)
        rightBtn.titleLabel?.font = .pingFangMedium(size: 16)
        rightBtn.setTitleColor(UIColor.black, for: .normal)
        //rightBtn.addTarget(self, action: #selector(presentCalendarView), for: .touchUpInside)
        self.view.addSubview(rightBtn)

        rightBtn.rx.tap.subscribe(onNext: {[weak self] in
            self?.presentCalendarView()
        }, onError: {_ in}, onCompleted: {print("完成")}, onDisposed: {print("释放")}).disposed(by:bag)
        
        
//        _ = Observable<String>.create{(obserber) -> Disposable in
//            obserber.onNext("发送信号")
//            return Disposables.create()
//        }.subscribe(onNext: {str in print(str)}, onDisposed: {print("订阅释放")}).dispose()
    }
    
    @objc func presentCalendarView(){
        let calendarView = CalendarView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight-SafeAreaBottomHeight))
        let windo = UIApplication.shared.keyWindow!
        windo.addSubview(calendarView)
        calendarView.doneHandle = { [weak self] model in
            
        }
        let com = YSDateTool.currentDateCom()
        calendarView.timeModel.year = com.year!
        calendarView.timeModel.month = com.month!
        calendarView.timeModel.day = com.day!
        calendarView.showAlertView()
    }
}

