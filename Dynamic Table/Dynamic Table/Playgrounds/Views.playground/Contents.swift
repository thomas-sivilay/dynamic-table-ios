import UIKit
import PlaygroundSupport
import SnapKit

typealias JSON = [String: Any]

let style: JSON = [
    "text": [ "size": 10],
    "title": [ "size": 16]
]

let json: [JSON] = [
    ["title": ["data": "Hello!", "style": ["padding": ["top": 0, "bottom": 0, "left": 10, "right": 10]]]],
    ["text": ["data": "Product description!", "style": ["padding": ["top": 0, "bottom": 0, "left": 10, "right": 10]]]],
    ["text": ["data": "Save it!", "style": ["padding": ["top": 0, "bottom": 0, "left": 10, "right": 10]]]],
]

struct Padding {
    let left: Int
    let right: Int
    let top: Int
    let bottom: Int
}

struct Style {
    let padding: Padding
    
    init(padding: Padding = Padding(left: 0, right: 0, top: 0, bottom: 0)) {
        self.padding = padding
    }
}

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
        makeConstraints(with: Style())
    }
    
    func configure(with text: String, style: Style) {
        label.text = text
        layer.borderColor = UIColor.cyan.cgColor
        layer.borderWidth = 1
        makeConstraints(with: style)
    }
    
    private func makeConstraints(with style: Style) {
        label.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(style.padding.top)
            make.bottom.equalToSuperview().offset(style.padding.bottom)
            make.left.equalToSuperview().offset(style.padding.left)
            make.right.equalToSuperview().offset(style.padding.right)
        }
    }
}

final class ViewController: UIViewController {
    
    private let loadedJSON: [JSON] = json
    
    private var layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp(view)
    }
    
    private func setUp(_ view: UIView) {
        view.backgroundColor = .blue
        
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: "textCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedJSON.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = loadedJSON[indexPath.row]
        print(data)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
        
        // HERE IS THE INTERESTING WORK..
        
        if let text = data["text"] as? String {
            let padding = Padding(left: 20, right: 20, top: 0, bottom: 0)
            let style = Style(padding: padding)
            cell.configure(with: text, style: style)
        } else {
            print("OOPS")
        }
        
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // DEFINE THE HEIGHT FOR A GIVEN DATA
        
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension ViewController: UICollectionViewDelegate {
    
}

PlaygroundPage.current.liveView = ViewController()
