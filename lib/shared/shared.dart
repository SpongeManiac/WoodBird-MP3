export '../platform_specific/unsupported.dart'
    if (dart.library.io) '../platform_specific/device.dart'
    if (dart.library.html) '../platform_specific/web.dart';
