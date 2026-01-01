class ImageManager {
  static final ImageManager _instance = ImageManager._internal();

  factory ImageManager() {
    return _instance;
  }

  ImageManager._internal();

  // Image asset paths
  static const String _basePath = 'assets/images/';

  // App images
  static const String background = '${_basePath}background.webp';
  static const String icLauncher = '${_basePath}ic_launcher.webp';
  static const String splashImage = '${_basePath}splash_image.webp';

  // Get image path by name
  String getImagePath(String name) {
    switch (name.toLowerCase()) {
      case 'background':
        return background;
      case 'ic_launcher':
      case 'launcher':
      case 'icon':
        return icLauncher;
      case 'splash_image':
      case 'splash':
        return splashImage;
      default:
        throw ArgumentError('Image not found: $name');
    }
  }

  // Get all available image names
  List<String> getAllImageNames() {
    return ['background', 'ic_launcher', 'splash_image'];
  }

  // Check if image exists
  bool hasImage(String name) {
    try {
      getImagePath(name);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get image paths by category
  Map<String, List<String>> getImagesByCategory() {
    return {
      'ui': [background, splashImage],
      'icons': [icLauncher],
    };
  }

  // Get all image paths
  List<String> getAllImagePaths() {
    return [background, icLauncher, splashImage];
  }
}
