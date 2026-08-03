import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Surface gradients that give a card depth from the inside.
///
/// The card reads as lifted because it is lit from one corner — a light source
/// at the top-right falling off toward the bottom-left — rather than because it
/// casts a shadow onto the page. Keeps surfaces flush with the background,
/// which is what dark UIs generally want.
abstract final class AppGradients {
  /// Colour of the lit corner when a card doesn't name one.
  ///
  /// Brand-tinted rather than plain white: white reads as nothing on a white
  /// card, so light mode got no lighting at all from a neutral sheen. Retheme
  /// via [AppColors.sheenDefault].
  static const defaultSheen = AppColors.sheenDefault;

  /// Corner-lit card surface built on top of [surface].
  ///
  /// Pass [color] to override the lit corner for an accent card; it defaults to
  /// [defaultSheen]. Set [strong] for the one hero card on a screen.
  static LinearGradient cardSheen(
    Color surface,
    bool isDark, {
    Color? color,
    bool strong = false,
  }) {
    final light = color ?? defaultSheen;

    // Dark surfaces take more sheen before it reads; on white the same alpha
    // would look like a colour wash rather than lighting.
    final litAlpha = switch ((strong, isDark)) {
      (true,  true)  => 0.24,
      (true,  false) => 0.24,
      (false, true)  => 0.14,
      (false, false) => 0.15,
    };

    // The far corner deepens so the fall-off stays readable even when the lit
    // corner is subtle. Light mode keeps this very shallow: the card is white
    // and must stay clearly lighter than the page across its whole surface, so
    // the shading here is a hint of depth, not separation.
    final shadeAlpha = isDark ? (strong ? 0.16 : 0.10) : (strong ? 0.03 : 0.02);

    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color.alphaBlend(light.withValues(alpha: litAlpha), surface),
        surface,
        Color.alphaBlend(
          AppColors.shadowInk.withValues(alpha: shadeAlpha),
          surface,
        ),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }
}
