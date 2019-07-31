import UIKit

class SpringyCollectionViewFlowLayout: UICollectionViewFlowLayout {
    private lazy var dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    private let columnWidth: CGFloat = 300
    private let rowHeight: CGFloat = 150
    
    override func prepare() {
        super.prepare()
        self.minimumLineSpacing = 25
        self.itemSize = CGSize(width: columnWidth, height: rowHeight)
        self.sectionInset = UIEdgeInsets(
            top: minimumInteritemSpacing,
            left: 0,
            bottom: 0,
            right: 0
        )
        self.sectionInsetReference = .fromSafeArea
        
        let contentBounds = CGRect(origin: .zero, size: collectionViewContentSize)
        guard let items = super.layoutAttributesForElements(in: contentBounds)
            else { return }
        
        if (self.dynamicAnimator.behaviors.count == 0) {
            for (_, object) in items.enumerated() {
                let behaviour = UIAttachmentBehavior(
                    item: object,
                    attachedToAnchor: object.center
                )
                
                behaviour.length = 0.0
                behaviour.damping = 0.8
                behaviour.frequency = 1.0
                
                self.dynamicAnimator.addBehavior(behaviour)
            }
        }
    }
    
    override func layoutAttributesForElements(
        in rect: CGRect
        ) -> [UICollectionViewLayoutAttributes]? {
        return dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }
    
    override func layoutAttributesForItem(
        at indexPath: IndexPath
        ) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView!
        
        let scrollDelta = newBounds.origin.y - scrollView.bounds.origin.y
        let touchLocation = scrollView.panGestureRecognizer.location(in: scrollView)
        
        for case let spring as UIAttachmentBehavior in dynamicAnimator.behaviors {
            let anchorPoint = spring.anchorPoint
            let yDistanceFromTouch = abs(touchLocation.y - anchorPoint.y)
            let xDistanceFromTouch = abs(touchLocation.x - anchorPoint.x)
            let scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / 1500
            
            let item = spring.items.first!
            var center = item.center
            if scrollDelta < 0 {
                center.y += max(scrollDelta, scrollDelta * scrollResistance)
            } else {
                center.y += min(scrollDelta, scrollDelta * scrollResistance)
            }
            item.center = center
            dynamicAnimator.updateItem(usingCurrentState: item)
        }
        
        return false
    }
}
