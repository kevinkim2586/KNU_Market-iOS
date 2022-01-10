import UIKit

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.cellId, for: indexPath) as? PostCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        
        let postDetail = reactor?.currentState.postModel?.postDetail ?? "로딩 중.."
        
//        let postDetail = viewModel.model?.postDetail ?? "로딩 중.."
//
        cell.title = postDetail
        
        cell.titleLabel.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderViewStyle()
    }
}
