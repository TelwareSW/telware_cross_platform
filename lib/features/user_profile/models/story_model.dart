class StoryModel {
  // Private fields
  String _userName;
  String _userImageUrl;
  String _storyContentType;
  dynamic _storyContent;
  DateTime _createdAt;

  // Constructor
  StoryModel({
    required String userName,
    required String userImageUrl,
    required DateTime createdAt,
    String storyContentType = 'image',
    dynamic storyContent = 'place holder for content',
  })  : _userName = userName,
        _userImageUrl = userImageUrl,
        _createdAt = createdAt,
        _storyContentType = storyContentType,
        _storyContent = storyContent;

  // Getters
  String get title => _userName;
  String get userImageUrl => _userImageUrl;
  DateTime get createdAt => _createdAt;
  String get storyContentType => _storyContentType;
  dynamic get storyContent => _storyContent;

  set title(String userName) {
    _userName = userName;
  }

  set imageUrl(String userImageUrl) {
    _userImageUrl = userImageUrl;
  }

  set createdAt(DateTime createdAt) {
    _createdAt = createdAt;
  }

  set storyContentType(String storyContentType) {
    _storyContentType = storyContentType;
  }

  set storyContent(dynamic storyContent) {
    _storyContent = storyContent;
  }
}
