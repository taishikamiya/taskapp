//
//  CategoryViewController.swift
//  taskapp
//
//  Created by Taishi Kamiya on 2020/06/13.
//  Copyright © 2020 taishi.kamiya. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UIViewController {

    @IBOutlet weak var newCategoryField: UITextField!

    var resultHandler: ((String) -> Void)?  //遷移先から処理を受け取る

    let realm = try! Realm()
    var cat: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            //print(self.newCategoryField.text!)
            if newCategoryField.text != nil {
                
                self.cat.categoryName = self.newCategoryField.text!
                print("catId = \(cat.catId), categooryName = \(cat.categoryName)")
                self.realm.add(self.cat, update: .modified)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func addCategory(_ sender: Any) {
        //nilチェック
        guard let text = self.newCategoryField.text else {return}
        
        //
        if let handler = self.resultHandler {
            handler(text)
        }
        
        self.dismiss(animated: true, completion: nil)
     //   performSegue(withIdentifier: "addCatSegue", sender: nil)
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
