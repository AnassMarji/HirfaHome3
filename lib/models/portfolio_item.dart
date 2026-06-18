
class PortfolioItem {
  final String beforeUrl;
  final String afterUrl;
  final String caption;

  const PortfolioItem({
    required this.beforeUrl,
    required this.afterUrl,
    required this.caption,
  });

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      beforeUrl: map['beforeUrl'] as String? ?? '',
      afterUrl: map['afterUrl'] as String? ?? '',
      caption: map['caption'] as String? ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'beforeUrl': beforeUrl,
      'afterUrl': afterUrl,
      'caption': caption,
    };
  }
}