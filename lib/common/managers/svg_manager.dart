class SvgManager {
  static final SvgManager _instance = SvgManager._internal();
  
  factory SvgManager() {
    return _instance;
  }
  
  SvgManager._internal();

  // SVG asset paths
  static const String _basePath = 'assets/svgs/';
  
  // Menu icons
  static const String contactLensesIcon = '${_basePath}contact_lenses_icon.svg';
  static const String lenses3dIcon = '${_basePath}lenses_3d_icon.svg';
  static const String manualIcon = '${_basePath}manual_icon.svg';
  static const String measurementsIcon = '${_basePath}measurements_icon.svg';
  static const String simulationsIcon = '${_basePath}simulations_icon.svg';
  static const String videoIcon = '${_basePath}video_icon.svg';
  static const String virtualMirrorIcon = '${_basePath}virtual_mirror_icon.svg';
  static const String visionTestIcon = '${_basePath}vision_test_icon.svg';

  // Menu items configuration
  static const List<MenuItemData> menuItems = [
    MenuItemData(
      title: 'Virtual Mirror',
      svgPath: virtualMirrorIcon,
    ),
    MenuItemData(
      title: 'Simulations',
      svgPath: simulationsIcon,
    ),
    MenuItemData(
      title: 'Lenses 3D',
      svgPath: lenses3dIcon,
    ),
    MenuItemData(
      title: 'Contact Lenses',
      svgPath: contactLensesIcon,
    ),
    MenuItemData(
      title: 'Measurements',
      svgPath: measurementsIcon,
    ),
    MenuItemData(
      title: 'Vision Test',
      svgPath: visionTestIcon,
    ),
    MenuItemData(
      title: 'Manual',
      svgPath: manualIcon,
    ),
    MenuItemData(
      title: 'Video',
      svgPath: videoIcon,
    ),
  ];

  // Get SVG path by name
  String getSvgPath(String name) {
    switch (name.toLowerCase()) {
      case 'contact_lenses':
      case 'contactlenses':
        return contactLensesIcon;
      case 'lenses_3d':
      case 'lenses3d':
        return lenses3dIcon;
      case 'manual':
        return manualIcon;
      case 'measurements':
        return measurementsIcon;
      case 'simulations':
        return simulationsIcon;
      case 'video':
        return videoIcon;
      case 'virtual_mirror':
      case 'virtualmirror':
        return virtualMirrorIcon;
      case 'vision_test':
      case 'visiontest':
        return visionTestIcon;
      default:
        throw ArgumentError('SVG not found: $name');
    }
  }

  // Get all available SVG names
  List<String> getAllSvgNames() {
    return [
      'contact_lenses',
      'lenses_3d',
      'manual',
      'measurements',
      'simulations',
      'video',
      'virtual_mirror',
      'vision_test',
    ];
  }

  // Check if SVG exists
  bool hasSvg(String name) {
    try {
      getSvgPath(name);
      return true;
    } catch (e) {
      return false;
    }
  }
}

// Data class for menu items
class MenuItemData {
  final String title;
  final String svgPath;

  const MenuItemData({
    required this.title,
    required this.svgPath,
  });
}