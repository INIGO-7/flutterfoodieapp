class Review {
  final String reviewerName;
  final double rating;
  final String comment;
  final String? avatarUrl;

  const Review({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.avatarUrl,
  });
}