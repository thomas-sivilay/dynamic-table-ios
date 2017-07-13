import UIKit
import PlaygroundSupport

typealias JSON = [String: Any]

let style: JSON = [
    "text": [ "size": 10],
    "title": [ "size": 16]
]

let json: JSON = [
    "title": "Hello!",
    "text": "Product A",
]



final class ViewController: UIViewController {
    
    private var collectionView: UICollectionView {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    init() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
}

let vc = ViewController()
PlaygroundPage.current.liveView = vc
