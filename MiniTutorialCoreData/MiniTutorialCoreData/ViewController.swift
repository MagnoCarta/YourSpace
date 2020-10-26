//
//  ViewController.swift
//  MiniTutorialCoreData
//
//  Created by Gilberto Magno on 10/21/20.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    //MARK: Properties
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    
    var person: Person? {
        didSet {
            guard let person = person else { return }
            //nameTextField.text = person.name
            view.backgroundColor = .white
          //  self.mainImageView = person.paintedBoard
            //self.tempImageView = person.tempPaintedBoard
        }
    }
    
     var coreDataStack = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //MARK: Views
    var buttons: [UIButton] = []
   
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var purpleButton: UIButton!
    
    lazy var saveEditButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.handleSavePerson))
        return barButton
    }()
    
    //MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.loadPerson()
            if self.person?.paintedBoard != nil {
            print("eoq")
                self.mainImageView.image = self.person?.paintedBoard?.image
            
        }
            if self.person?.tempPaintedBoard != nil {
            print("eeq")
                self.tempImageView.image = self.person?.tempPaintedBoard?.image
        }
        
        
        print(person?.name)
        
            self.setupViews()
        
    }
    
    //MARK: Methods
    ///Load the first Person from our CoreData
    func loadPerson() {
       
        let personFetchRequest: NSFetchRequest<Person> = Person.fetchRequest() //make a Person Entity fetch request
        do {
            let results = try self.coreDataStack.fetch(personFetchRequest)
            
            
            if results.count > 0 {
                //person found
                self.person = results.first
        
                if self.person?.colors == nil {
                    
                    self.person?.colors = [.red,.blue,.yellow,.black,.cyan,.green]
                    
                }
            } else { //no person found
                
                
                self.person = Person(context: self.coreDataStack)
                if self.person?.colors == nil {
                    
                    self.person?.colors = [.red,.blue,.yellow,.black,.cyan,.green]
                    
                }
                (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            }
        } catch let error as NSError {
            print("Error: \(error) description: \(error.userInfo)")
        }
        
    }
    
    ///save person to our CoreData
    @objc func handleSavePerson() {
        
       
        person!.colors = [.red, .orange, .yellow, .green, .blue, .purple]
        person!.favoriteColor = person!.favoriteColor
        person!.paintedBoard = self.mainImageView
        person!.tempPaintedBoard = self.tempImageView
        person?.name = "novoTeste"
        //save the managed object context
        do {
            
            try coreDataStack.save()
        } catch let error as NSError {
            print("Error: \(error), description: \(error.userInfo)")
        }
    }
    
    ///update view's background color with the sender's background color. Update favoriteColor and
    @objc func colorButtonTapped(_ sender: Any) {
        let button = sender as? UIButton
        guard let color = button?.backgroundColor else { return }
       // view.backgroundColor = color
        person!.favoriteColor = color
        button?.layer.borderColor = UIColor.white.cgColor
        for coloredButton in buttons where coloredButton != button {
            coloredButton.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      swiped = false
      lastPoint = touch.location(in: view)
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        
        guard let persona = person else {
            return
        }
        
      // 1
      UIGraphicsBeginImageContext(view.frame.size)
      guard let context = UIGraphicsGetCurrentContext() else {
        return
      }
      tempImageView.image?.draw(in: view.bounds)
        
      // 2
      context.move(to: fromPoint)
      context.addLine(to: toPoint)
      
      // 3
      context.setLineCap(.round)
      context.setBlendMode(.normal)
      context.setLineWidth(brushWidth)
        guard let favoriteColor = persona.favoriteColor else {return}
        context.setStrokeColor(favoriteColor.cgColor)
      
      // 4
      context.strokePath()
      
      // 5
      tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      tempImageView.alpha = opacity
      UIGraphicsEndImageContext()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }

      // 6
      swiped = true
      let currentPoint = touch.location(in: view)
      drawLine(from: lastPoint, to: currentPoint)
        
      // 7
      lastPoint = currentPoint
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      if !swiped {
        // draw a single point
        drawLine(from: lastPoint, to: lastPoint)
      }
        
      // Merge tempImageView into mainImageView
      UIGraphicsBeginImageContext(mainImageView.frame.size)
      mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
      tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
      mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
        
      tempImageView.image = nil
    }
    
    
    
}

private extension ViewController {
    func setupViews() {
        setupNavigationBar()
        setupButtons()
      //  nameTextField.delegate = self
    }
    
    func setupButtons() {
        buttons = [redButton, orangeButton, yellowButton,
                   greenButton, blueButton, purpleButton]
        for button in buttons { //round their corners
            button.layer.cornerRadius = 25
            button.layer.masksToBounds = true
            button.layer.borderWidth = 5
            button.layer.borderColor = UIColor.clear.cgColor
            button.addTarget(self, action: #selector(colorButtonTapped(_:)), for: .touchUpInside)
        }
        guard let persona = person else{ return }
        guard let colors = persona.colors else { return }
        if colors.count == 0 {
            view.backgroundColor = person?.favoriteColor
            person!.colors = [.red, .orange, .yellow, .green, .blue, .purple]
        }
        
        for (index, button) in buttons.enumerated() {
            
            button.backgroundColor = colors[index]
            
            if let favColor = person?.favoriteColor, favColor == button.backgroundColor! {
                button.layer.borderColor = UIColor.white.cgColor
            }
        }
    }
    
    func setupNavigationBar() {
        title = "PINTE SUA AREA"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        navigationItem.rightBarButtonItem = saveEditButton
    }
    
    
    
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
