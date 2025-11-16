import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationIndexProvider = StateProvider.autoDispose<int>((ref) => 1); // Home por defecto
