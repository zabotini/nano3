//
//  TasksTableViewController.swift
//  nano3
//
//  Created by Rafael Zabotini on 12/02/18.
//  Copyright © 2018 Rafael Zabotini. All rights reserved.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    
    // MARK: - Properties
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
			return .lightContent
	}
	
    var resultsController: NSFetchedResultsController<Task>!
    let coreDataStack = CoreDataStack()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setNeedsStatusBarAppearanceUpdate()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Request
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        //MARK: Init
        request.sortDescriptors = [sortDescriptor]
        request.predicate = NSPredicate(format: "done == false")
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        resultsController.delegate = self
        
        //MARK: Fetch
        do {
            try resultsController.performFetch()
        } catch {
            print("Error when performing fetch: \(error)")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let Task = resultsController.object(at: indexPath)
        cell.textLabel?.text = Task.title
        switch Task.category {
        case Int16(0) :
            cell.detailTextLabel?.text = "• Fun •"
            cell.detailTextLabel?.borderColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 0.3043931935)
        case Int16(1) :
            cell.detailTextLabel?.text = "• Skill •"
            cell.detailTextLabel?.borderColor = #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 0.1971586045)
        case Int16(2) :
            cell.detailTextLabel?.text = "• Random •"
            cell.detailTextLabel?.borderColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 0.2986943493)
        default:
            cell.detailTextLabel?.text = "???"
        }
        
        return cell
    }
    
    //MARK: - Table View Override Delegates
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let Task = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(Task)
            
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Error when performing delete operation: \(error)")
                completion(false)
            }
        }
        action.image = #imageLiteral(resourceName: "Trash")
        action.backgroundColor = #colorLiteral(red: 1, green: 0.256580419, blue: 0.3740505642, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Check") { (action, view, completion) in
            
            let Task = self.resultsController.object(at: indexPath)
            Task.done = true
            self.resultsController.managedObjectContext.refresh(Task, mergeChanges: true)
            
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Error when performing check operation: \(error)")
                completion(false)
            }
        }
        action.image = #imageLiteral(resourceName: "Check")
        action.backgroundColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowAddTask", sender: tableView.cellForRow(at: indexPath))
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddTaskViewController {
            vc.managedContext = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let vc = segue.destination as? AddTaskViewController {
            vc.managedContext = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let Task = resultsController.object(at: indexPath)
                vc.task = Task
            }
        }
    }
    
}

extension TasksTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let Task = resultsController.object(at: indexPath)
                cell.textLabel?.text = Task.title
                
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
}
