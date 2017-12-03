//
//  ViewController.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import RxSwift

enum ARViewType {
    case waitingForUserTap, waitingForResults(identifier: String), failedToGetResults, resultDisplayed
}

class ViewController: UIViewController, ARSKViewDelegate, SceneDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var sceneView: ARSKView!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var markerView: UIView!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var buyView: UIView!
    @IBOutlet weak var buyCollectionView: UICollectionView!
    @IBOutlet weak var buyViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buyViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var instructionsView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var instructionsViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var productDetailsView: UIView!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var nutritionFactsLabel: UILabel!
    
    @IBAction func didTapRecognize(_ sender: Any) {
        if let scene = sceneView.scene as? Scene {
            scene.findObject()
        }
    }
    
    @IBAction func didTapReset(_ sender: Any) {
        self.food = nil
        self.data = nil
        buyCollectionView.reloadData()
        arViewType = .waitingForUserTap
        if let scene = sceneView.scene as? Scene {
            scene.removeAnchor()
        }
    }
    
    var repository: Repository! = Repository.instance
    var food: Food?
    
    let disposeBag = DisposeBag()
    
    var arViewType: ARViewType = ARViewType.waitingForUserTap {
        didSet {
            switch arViewType {
            case .waitingForUserTap:
                self.resetButton.isHidden = true
                self.markerView.isHidden = false
                self.boxView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.instructionsLabel.text = "Place the object inside the screen then tap it"
                self.showInstructions()
                self.hideBuy()
            case .waitingForResults:
                self.resetButton.isHidden = true
                self.markerView.isHidden = false
                self.boxView.isHidden = true
                self.activityIndicator.startAnimating()
                self.hideInstructions()
                self.hideBuy()
            case .failedToGetResults:
                let alert = UIAlertController(title: "Error", message: "Failed to get results", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                self.resetButton.isHidden = true
                self.markerView.isHidden = false
                self.boxView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.instructionsLabel.text = "Place the object inside the screen then tap it"
                self.showInstructions()
                self.hideBuy()
            case .resultDisplayed:
                self.resetButton.isHidden = false
                self.markerView.isHidden = true
                self.boxView.isHidden = true
                self.activityIndicator.startAnimating()
                self.hideInstructions()
                self.showBuy()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        //sceneView.showsFPS = true
        //sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        if let scene = sceneView.scene as? Scene {
            scene.sceneDelegate = self
        }
        
        self.arViewType = .waitingForUserTap
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - Helper methods
    
    func showBuy() {
        self.buyViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func hideBuy() {
        self.buyViewBottomConstraint.constant = -self.buyViewHeightConstraint.constant
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func showInstructions() {
        self.instructionsViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func hideInstructions() {
        self.instructionsViewBottomConstraint.constant = -self.instructionsView.frame.height
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }
    
    func getCaptionNode(food: Food) -> SKNode {
        foodLabel.text = food.name
        var nutrients = ""
        for nutrient in food.nutrients {
            if !nutrients.isEmpty {
                nutrients += "\n"
            }
            nutrients += "\(nutrient.label!) \(nutrient.quantity!)\(nutrient.unit!)"
        }
        nutritionFactsLabel.text = nutrients
        productDetailsView.layoutIfNeeded()
        let texture = SKTexture(image: getImage(view: productDetailsView))
        return SKSpriteNode(texture: texture)
    }
    
    func getImage(view: UIView) -> UIImage {
        let bounds = view.bounds
        let bg = view.backgroundColor
        
        view.backgroundColor = UIColor.white
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        view.bounds = bounds
        view.backgroundColor = bg
        return image!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details", let vc = segue.destination as? MerchantViewController,
            let (restaurant, food) = sender as? (Restaurant, Food) {
            vc.restaurant = restaurant
            vc.food = food
        }
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        guard let food = self.food else {
            return nil
        }
        
        // Create and configure a node for the anchor added to the view's session.
        return getCaptionNode(food: food)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: SceneDelegate
    
    func didFailToFindObject() {
        arViewType = .failedToGetResults
    }
    
    func didDetectObject(identifier: String) {
        arViewType = .waitingForResults(identifier: identifier)
        let param = FoodParam(food: identifier)
        repository.search(param: param).subscribe(onNext: { food in
            self.food = food
            self.data = food.restaurants
            self.buyCollectionView.reloadData()
            self.arViewType = .resultDisplayed
        }, onError: { error in
            self.arViewType = .failedToGetResults
        }).addDisposableTo(disposeBag)
    }
    
    // MARK - Collection View
    
    let kScrollOffset: CGFloat = 0.3
    let kCellMargin: CGFloat = 0.0
    var kAccountDetailCellScreenOccupancy: CGFloat = 1.0
    var kCellSize: CGSize?
    var data:[Restaurant]?
    var selectedIndexPath: IndexPath?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCellSize()
    }
    
    func setCellSize() {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width //* kAccountDetailCellScreenOccupancy
        //        let widthLimit: CGFloat = 375
        //        if width > widthLimit {
        //            width = widthLimit
        //            //kAccountDetailCellScreenOccupancy = widthLimit/screenSize.width
        //        }
        let itemSize = CGSize(width: width, height: 126.0)
        kCellSize = itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId = "merchantCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MerchantCollectionViewCell
        cell.set(restaurant: data![indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let screenWidth = UIScreen.main.bounds.width
        let margin = screenWidth * (1 - kAccountDetailCellScreenOccupancy)
        return UIEdgeInsets(top: 0, left: margin/2.0, bottom: 0, right: margin/2.0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kCellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kCellMargin
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let restaurant = data![indexPath.row]
        if !restaurant.isProntoMerchant {
            if let link = URL(string: restaurant.url) {
                UIApplication.shared.open(link)
            }
        } else {
            performSegue(withIdentifier: "details", sender: (restaurant, food))
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee.x = scrollView.contentOffset.x
        
        //check if scrolled is 30% of the screen, snap to next/prev cell
//        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
//        if (actualPosition.x >= UIScreen.main.bounds.size.width * kScrollOffset){
//            if((selectedIndexPath?.row)!>0) { snapToIndex(index: (selectedIndexPath?.row)! - 1)
//                scrollView.isScrollEnabled = false}
//        }else if (actualPosition.x <= UIScreen.main.bounds.size.width * -kScrollOffset){
//            if((selectedIndexPath?.row)!<(data?.count)!-1) { snapToIndex(index: (selectedIndexPath?.row)! + 1)
//                scrollView.isScrollEnabled = false}
//        }else{
//            snapToIndex()
//        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return kCellSize!
    }
    
    func snapToIndex(index: Int? = nil) {
        let index = index ?? getNearestIndex()
        let indexPath = IndexPath(item: index, section: 0)
        buyCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        selectedIndexPath = indexPath
    }
    
    func getNearestIndex() -> Int {
        let cellWidth = kCellSize!.width
        for i in 0..<buyCollectionView.numberOfItems(inSection: 0) {
            let limit = CGFloat(i) * cellWidth + cellWidth / 2.0 + kCellMargin * CGFloat(i)
            if buyCollectionView.contentOffset.x <= limit{
                return i
            }
        }
        return 0
    }
    
}
