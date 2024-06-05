import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CustomLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 // Number of slides
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // Configure the cell (e.g., add a UILabel or UIImageView)
        cell.backgroundColor = UIColor(hue: CGFloat(indexPath.item) / 4.0, saturation: 0.8, brightness: 0.8, alpha: 1.0)
        
        return cell
    }
}







import UIKit

class CustomLayout: UICollectionViewFlowLayout {
    let activeDistance: CGFloat = 200
    let zoomFactor: CGFloat = 0.3
    let spacing: CGFloat = 40
    
    override func prepare() {
        super.prepare()
        scrollDirection = .horizontal
        minimumLineSpacing = spacing
        itemSize = CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let items = super.layoutAttributesForElements(in: rect)?.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        
        for attributes in items! {
            if attributes.frame.intersects(visibleRect) {
                let distance = visibleRect.midX - attributes.center.x
                let normalizedDistance = distance / activeDistance
                
                let zoom = 1 + zoomFactor * (1 - abs(normalizedDistance))
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1.0)
                attributes.zIndex = Int(zoom.rounded())
            }
        }
        return items
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let items = layoutAttributesForElements(in: collectionView!.bounds)
        let center = collectionView!.bounds.size.width / 2
        let proposedContentOffsetCenterX = proposedContentOffset.x + center
        
        let closest = items!.sorted { abs($0.center.x - proposedContentOffsetCenterX) < abs($1.center.x - proposedContentOffsetCenterX) }.first!
        
        return CGPoint(x: floor(closest.center.x - center), y: proposedContentOffset.y)
    }
}
