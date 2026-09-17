export 'visual_search_engine_native.dart'
  if (dart.library.html) 'visual_search_engine_web.dart'
  if (dart.library.js_interop) 'visual_search_engine_web.dart';
