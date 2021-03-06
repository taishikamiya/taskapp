//
//  ViewController.swift
//  taskapp
//
//  Created by Taishi Kamiya on 2020/06/07.
//  Copyright © 2020 taishi.kamiya. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!  // search bar
    var searchText: String? = ""
    
    let realm = try! Realm()
    
    var cat = try! Realm().objects(Category.self)
    
//    var pickerView:  UIPickerView = UIPickerView()
    
    @IBOutlet weak var searchCatPickerView: UIPickerView!
    
    //DB内のタスクが格納されるリスト
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //検索結果格納用
//    var resultArray: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate  =  self
        searchBar.placeholder = "category名で検索"
        searchBar.showsCancelButton =  true
//        searchBar.showsSearchResultsButton = true
     
        searchCatPickerView.delegate = self
        searchCatPickerView.dataSource = self
        searchCatPickerView.reloadInputViews()

//        createPickerView()
    }

    
//PickerView
    
    // picker view
    
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView == searchCatPickerView {
                return cat.count
            } else {
                return 0
            }
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            if pickerView == searchCatPickerView {
                return cat[row].categoryName
            } else {
                return ""
            }
        }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView == searchCatPickerView {

            searchBar.text = cat[row].categoryName

            searchText = searchBar.text!

            // フィルターされた結果を取得
            taskArray = try!  Realm().objects(Task.self).filter("category==%@", searchText!)
            tableView.reloadData()
        } else {
            
        }
        }
    
/*
    func createPickerView(){
        //        pickerView.delegate = self
        
        //ここが解決してない。searchBarをタップしてpickerを表示したい。
        //searchBar.inputView = self.pickerView
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.frame =  CGRect(x:0, y:0, width:self.view.frame.width, height:44)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InputViewController.donePicker))
        toolbar.setItems([doneButtonItem], animated: true)
        searchBar.inputAccessoryView = toolbar
    }

    @objc func donePicker() {
        searchBar.endEditing(true)
    }
 */
    
    @objc func dismissKeyboard() {
        //キーボードを閉じる
        view.endEditing(true)
    }


    // searchBarがタップされたとき
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        dismissKeyboard()
        searchCatPickerView.isHidden = false;
    }
    
    // searchBarを終了したとき
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchCatPickerView.isHidden = true;
        searchBar.text = ""

    }
    
    // xボタンが押されたときの処理
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
/*
        searchCatPickerView.isHidden = true;

        if searchText.isEmpty {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
            tableView.reloadData()
        }
  */
        self.view.endEditing(true)
        searchCatPickerView.isHidden = true;

        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }
    
    //検索
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchCatPickerView.isHidden = true;

        self.view.endEditing(true)
        searchText = searchBar.text!

        // フィルターされた結果を取得
        taskArray = try!  Realm().objects(Task.self).filter("category==%@", searchText!)
        tableView.reloadData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchCatPickerView.isHidden = true;
        searchBar.text = ""
        
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }

    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //Cellに値を設定する
        let task = taskArray[indexPath.row]
 //      cell.textLabel?.text = task.title
        let label1 = cell.viewWithTag(1) as! UILabel
        label1.text = task.title

        //date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
//        cell.detailTextLabel?.text = dateString
        let label2 = cell.viewWithTag(2) as! UILabel
        label2.text = dateString


        //category
   //     cell.detailTextLabel?.text = task.category  // 一旦detailTextLabelというのを使う。
        let label3 = cell.viewWithTag(3) as! UILabel
        label3.text = task.category
        
        return cell
    }
    
    
    //各セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //Deleteボタンが押された時に呼ばれるメソッド
    func tableView(_  tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            //削除するタスクを取得
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            //未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests {
                (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-----------")
                    print(request)
                    print("-----------/")
                    
                }
            }
        }
    }
    
    //segueで画面遷移するときに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    //入力画面から帰ってきたときにTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        searchCatPickerView.reloadInputViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchCatPickerView.reloadAllComponents()
    }
    
}

