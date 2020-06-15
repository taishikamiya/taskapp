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

    let realm = try! Realm()
    var cat: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write{
            //print(self.newCategoryField.text!)
            if self.newCategoryField.text != nil {
                           
//                let allCategory = realm.objects(Category.self)
//                if allCategory.count != 0 {
//                    self.cat.catId = allCategory.count
//                }
                
                self.cat.categoryName = self.newCategoryField.text!
                print("categooryName = \(cat.categoryName)")
            }
        }
        super.viewWillDisappear(animated)
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
