import UIKit
import PlaygroundSupport
import SnapKit

typealias JSON = [String : Any]

protocol Data { }

protocol Style {
    var padding: Padding { get }
}

extension Style {
    var padding: Padding { return Padding(left: 0, right: 0, top: 0, bottom: 0) }
}

struct TextData: Codable, Data {
    let text: String
}

struct ImageData: Codable, Data {
    let url: String
}

struct TextStyle: Codable, Style {
    let size: Float
    let padding: Padding
}

struct Padding: Codable {
    let left: Int
    let right: Int
    let top: Int
    let bottom: Int
}

struct ImageStyle: Codable, Style { }

final class Element<Data, Style> {
    var data: Data
    var style: Style
    
    init(data: Data, style: Style) {
        self.data = data
        self.style = style
    }
}

enum UIElement: Decodable {
    case title(Element<TextData, TextStyle>)
    case text(Element<TextData, TextStyle>)
    
    case image(data: ImageData, style: ImageStyle)
}

extension UIElement {
    
    private enum CodingKeys: String, CodingKey {
        case type
        case data
        case style
    }
    
    enum UIElementCodingError: Error {
        case decoding(String)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let type = try? values.decode(String.self, forKey: .type) {
            switch type {
            case "text":
                if
                    let data = try? values.decode(TextData.self, forKey: .data),
                    let style = try? values.decode(TextStyle.self, forKey: .style)
                {
                    self = .text(Element(data: data, style: style))
                    return
                } else {
                    throw UIElementCodingError.decoding("Text Error")
                }
            case "title":
                if
                    let data = try? values.decode(TextData.self, forKey: .data),
                    let style = try? values.decode(TextStyle.self, forKey: .style)
                {
                    self = .title(Element(data: data, style: style))
                    return
                } else {
                    throw UIElementCodingError.decoding("Title Error")
                }
            case "image":
                if
                    let data = try? values.decode(ImageData.self, forKey: .data),
                    let style = try? values.decode(ImageStyle.self, forKey: .style)
                {
                    self = .image(data: data, style: style)
                    return
                } else {
                    throw UIElementCodingError.decoding("Image Error")
                }
            default:
                throw UIElementCodingError.decoding("Unknown key \(type)")
            }
        } else {
            throw UIElementCodingError.decoding("Wow Error")
        }
    }
}

let style = """
{
    "text":
    {"size": 16},
    "title":
    {"size": 24}
}
""".data(using: .utf8)!

let json = """
[
    {
        "type": "title",
        "data": {"text": "Hello!"},
         "style": {"padding": {"top": 0, "bottom": 0, "left": 20, "right": 20}, "size": 24}
    },
    {
        "type": "text",
        "data": {"text": "Hello!"},
         "style": {"padding": {"top": 0, "bottom": 0, "left": 10, "right": 10}, "size": 14}
    },
]
""".data(using: .utf8)!

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
    }
    
    func configure(with data: TextData, style: Style) {
        label.text = data.text
        
        if let style = style as? TextStyle {
            label.font = UIFont.systemFont(ofSize: CGFloat(style.size))
        }
        
        print(style)
        
        // DEBUG
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
    
    private var layout = UICollectionViewFlowLayout()
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var elements = [UIElement]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp(view)
        loadData()
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
    
    private func loadData() {
        let decoder = JSONDecoder()
        do {
            elements = try decoder.decode([UIElement].self, from: json)
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let element = elements[indexPath.row]
        return configuredCell(for: element, at: indexPath)
    }
    
    private func configuredCell(for element: UIElement, at indexPath: IndexPath) -> UICollectionViewCell {
        
        switch element {
        case let .image(data: _, style: _):
            print("oops")
            return UICollectionViewCell()
        case let .text(element):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            cell.configure(with: element.data, style: element.style)
            return cell
        case let .title(element):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textCell", for: indexPath) as! TextCell
            cell.configure(with: element.data, style: element.style)
            return cell
        }
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
