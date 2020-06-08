//
//  ViewController.swift
//  taskapp
//
//  Created by Taishi Kamiya on 2020/06/07.
//  Copyright © 2020 taishi.kamiya. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!  // search bar
    var searchText: String? = ""
    
    let realm = try! Realm()
    
    //DB内のタスクが格納されるリスト
    //日付の近い順でソート：昇順
    //以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    //検索結果格納用
    var resultArray: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate  =  self
        searchBar.placeholder = "category名で検索"
        
    }

    
    //検索
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
//        print(searchBar.text!)
        searchText = searchBar.text!
        print(resultArray.count)
    }

    //データの数を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchText != "" {
            print(resultArray.count)
            return  resultArray.count
        } else {
        return taskArray.count
        }
    }

    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再利用可能なセルを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        //Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title

        //category
        cell.detailTextLabel?.text = task.category  // 一旦detailTextLabelというのを使う。

        //  セルのcategory名を検索Wordと比較
            if searchText == task.category {
                resultArray.append(task)
            }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString

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
    }
}

