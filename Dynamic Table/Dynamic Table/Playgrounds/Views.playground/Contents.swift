import UIKit
import PlaygroundSupport
import SnapKit

typealias JSON = [String: Any]

let style: JSON = [
    "text": [ "size": 10],
    "title": [ "size": 16]
]

let json: [JSON] = [
    ["title": "Hello!"],
    ["text": "Product A"],
]

final class TextCell: UICollectionViewCell {
    
    private let label = UILabel()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with text: String) {
        label.text = text
    }
}

final class ViewController: UIViewController {
    
    private let loadedJSON: [JSON] = json
    
    private var collectionView: UICollectionView {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.backgroundColor = .white
            collectionView.register(TextCell.self, forCellWithReuseIdentifier: "textCell")
        }
    }
    
    init() {
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        super.init(nibName: nil, bundle: nil)
        setUp(view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setUp(_ view: UIView) {
        view.addSubview(collectionView)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedJSON.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = loadedJSON[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
        
        if let text = data["text"] as? String {
            cell.configure(with: text)
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
}

let vc = ViewController()
PlaygroundPage.current.liveView = vc
