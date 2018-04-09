//
//  ViewController.swift
//  Todoey
//
//  Created by Shawn Jiang on 4/6/18.
//  Copyright © 2018 Shawn Jiang. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems:Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    // let defaults = UserDefaults.standard
    // let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.color else {fatalError()}
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "28AAC0")
    }
    
    func updateNavBar(withHexCode colorHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist")}
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.barTintColor = navBarColor
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        searchBar.barTintColor = navBarColor
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            //Ternary operator ==>
            // value = condition ? valueIfTrue : valueIfFalse
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    //MARK - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = self.todoItems?[indexPath.row]{
            do{
                try self.realm.write {
                    item.done = !item.done
                }
            }
            catch{
                print("Error updating done attribute \(error)")
            }
        }
        tableView.reloadData()
        
    //    todoItems[indexPath.row].done = !todoItems[indexPath.row].done
        
    //    saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    //MARK: - Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(item)
                    print("Item deleted")
                }
            }
            catch{
                print("Error deleting Item \(error)")
            }
        }
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            if let currentCategory = self.selectedCategory {
                do{
                    try self.realm.write{
                    let newItem = Item()
                    newItem.title = textField.text!
                    newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("Error appending new Item to Category \(error)")
                }
            }
            self.tableView.reloadData()
    }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manipulation Methods
    
//    func saveItems(){
//        do{
//            try context.save()
//        }
//        catch{
//            print("Error saving context \(error)")
//        }
//
//        self.tableView.reloadData()
//    }
    
    func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
//
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        }else{
//            request.predicate = categoryPredicate
//        }
////        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, predicate])
////
////        request.predicate = compoundPredicate
//        do{
//            itemArray = try context.fetch(request)
//        }
//        catch{
//            print("Error fetching content \(error)")
//        }
     tableView.reloadData()
    }
    
}
//MARK: - Search Bar Methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
//        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

