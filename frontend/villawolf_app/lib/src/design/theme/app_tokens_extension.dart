import 'package:flutter/material.dart';

import '../tokens/semantic_tokens.dart';

/// Ergonomic access to the active [AppTokens] from any widget: `context.tokens.brand`.
extension AppTokensX on BuildContext {
  AppTokens get tokens =>
      Theme.of(this).extension<AppTokens>() ?? AppTokens.dark();
}
