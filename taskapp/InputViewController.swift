//
//  InputViewController.swift
//  taskapp
//
//  Created by Taishi Kamiya on 2020/06/07.
//  Copyright © 2020 taishi.kamiya. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var categoryTextField: UITextField!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
//    var cat: Category!
    var cat = try! Realm().objects(Category.self)

    //カテゴリ選択用ピッカー
    var pickerView: UIPickerView = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        //背景をタップしたらdismissKeyboardメソッドを呼ぶ
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        categoryTextField.text = task.category //0608
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        createPickerView()
    }
    
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }
    
    
    // Picker test用
    var data = ["A1","B2","C3"]
    
    // picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return data.count
        return cat.count
//        return cat.categoryName.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cat[row].categoryName
//        return ""
//        data[row]
//        return cat.categoryName[row]

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//            categoryTextField.text = data[row]
        categoryTextField.text = cat[row].categoryName
    }
    
    func createPickerView(){
        pickerView.delegate = self
        categoryTextField.inputView = pickerView
        //toolbar
        let toolbar = UIToolbar()
        toolbar.frame =  CGRect(x:0, y:0, width:self.view.frame.width, height:44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InputViewController.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        categoryTextField.inputAccessoryView = toolbar
    }

    @objc func donePicker() {
        categoryTextField.endEditing(true)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.category = self.categoryTextField.text! //0608
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        //titleと内容を設定
        if task.title == "" {
            content.title = "(タイトルなし)"
            
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        //ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        //identifier, content,  triggerからローカル通知を作成(idが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")   // errorがnilならローカル通知の登録に成功を表示。errorならerror
        }
        
        //未知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests {
            (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/----------")
                print(request)
                print("----------/")
            }
        }
    }
    
    //入力画面から帰ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryTextField.reloadInputViews()
    }
    
    //segueで画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "addCatSegue" {
            let categoryViewController:CategoryViewController = segue.destination as! CategoryViewController

            categoryViewController.resultHandler = { text in
                self.categoryTextField.text = text
            }
            let cat = Category()
            let allCategory = realm.objects(Category.self)
            if allCategory.count != 0 {
                cat.catId = allCategory.max(ofProperty: "catId")! + 1
            }
            
            categoryViewController.cat = cat
        print("test\(cat)")
            }
    }
     
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
