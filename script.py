import re

with open(r'q:\REPO\digipad\lib\features\nearby_sync\nearby_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if "import 'package:digipad_flutter/features/nearby_sync/debug_logger.dart';" not in content:
    content = content.replace("import 'package:nearby_connections/nearby_connections.dart';", 
                              "import 'package:nearby_connections/nearby_connections.dart';\nimport 'package:digipad_flutter/features/nearby_sync/debug_logger.dart';")

content = re.sub(r'debugPrint\((.*?error.*?)\);', r'DebugLogger.instance.error(\1);', content)
content = re.sub(r'debugPrint\((.*?)\);', r'DebugLogger.instance.info(\1);', content)

with open(r'q:\REPO\digipad\lib\features\nearby_sync\nearby_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)
