import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animaciones reutilizables para la aplicación
class AppAnimations {
  
  /// Duración estándar para animaciones
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);
  
  /// Curvas de animación personalizadas
  static const Curve bounceInCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve fastCurve = Curves.easeOutCubic;
  
  /// Widget de botón con animación de escala
  static Widget scaleButton({
    required Widget child,
    required VoidCallback onPressed,
    double scaleFactor = 0.95,
    Duration duration = shortDuration,
    Curve curve = fastCurve,
    bool hapticFeedback = true,
  }) {
    return ScaleAnimationButton(
      child: child,
      onPressed: onPressed,
      scaleFactor: scaleFactor,
      duration: duration,
      curve: curve,
      hapticFeedback: hapticFeedback,
    );
  }
  
  /// Widget de botón con animación de elevación
  static Widget elevationButton({
    required Widget child,
    required VoidCallback onPressed,
    double normalElevation = 4.0,
    double pressedElevation = 8.0,
    Duration duration = shortDuration,
    bool hapticFeedback = true,
  }) {
    return ElevationAnimationButton(
      child: child,
      onPressed: onPressed,
      normalElevation: normalElevation,
      pressedElevation: pressedElevation,
      duration: duration,
      hapticFeedback: hapticFeedback,
    );
  }
  
  /// Animación de fade in para widgets
  static Widget fadeIn({
    required Widget child,
    Duration duration = mediumDuration,
    Duration delay = Duration.zero,
    Curve curve = smoothCurve,
  }) {
    return FadeInAnimation(
      child: child,
      duration: duration,
      delay: delay,
      curve: curve,
    );
  }
  
  /// Animación de slide desde abajo
  static Widget slideFromBottom({
    required Widget child,
    Duration duration = mediumDuration,
    Duration delay = Duration.zero,
    double offset = 50.0,
  }) {
    return SlideFromBottomAnimation(
      child: child,
      duration: duration,
      delay: delay,
      offset: offset,
    );
  }
  
  /// Loading spinner personalizado
  static Widget loadingSpinner({
    Color? color,
    double size = 24.0,
  }) {
    return CustomLoadingSpinner(
      color: color,
      size: size,
    );
  }
  
  /// Transición personalizada entre páginas
  static PageRouteBuilder createPageRoute({
    required Widget page,
    PageTransitionType type = PageTransitionType.slideFromRight,
    Duration duration = mediumDuration,
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case PageTransitionType.slideFromRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: smoothCurve,
              )),
              child: child,
            );
          case PageTransitionType.slideFromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: smoothCurve,
              )),
              child: child,
            );
          case PageTransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case PageTransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.8,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: smoothCurve,
              )),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
        }
      },
    );
  }
}

/// Tipos de transición entre páginas
enum PageTransitionType {
  slideFromRight,
  slideFromBottom,
  fade,
  scale,
}

/// Botón con animación de escala
class ScaleAnimationButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scaleFactor;
  final Duration duration;
  final Curve curve;
  final bool hapticFeedback;

  const ScaleAnimationButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.scaleFactor = 0.95,
    this.duration = AppAnimations.shortDuration,
    this.curve = AppAnimations.fastCurve,
    this.hapticFeedback = true,
  });

  @override
  State<ScaleAnimationButton> createState() => _ScaleAnimationButtonState();
}

class _ScaleAnimationButtonState extends State<ScaleAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    if (widget.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Botón con animación de elevación
class ElevationAnimationButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double normalElevation;
  final double pressedElevation;
  final Duration duration;
  final bool hapticFeedback;

  const ElevationAnimationButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.normalElevation = 4.0,
    this.pressedElevation = 8.0,
    this.duration = AppAnimations.shortDuration,
    this.hapticFeedback = true,
  });

  @override
  State<ElevationAnimationButton> createState() =>
      _ElevationAnimationButtonState();
}

class _ElevationAnimationButtonState extends State<ElevationAnimationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.normalElevation,
      end: widget.pressedElevation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        if (widget.hapticFeedback) {
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: _elevationAnimation.value,
                  offset: Offset(0, _elevationAnimation.value / 2),
                ),
              ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animación fade in
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.duration = AppAnimations.mediumDuration,
    this.delay = Duration.zero,
    this.curve = AppAnimations.smoothCurve,
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Iniciar animación después del delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

/// Animación slide desde abajo
class SlideFromBottomAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offset;

  const SlideFromBottomAnimation({
    super.key,
    required this.child,
    this.duration = AppAnimations.mediumDuration,
    this.delay = Duration.zero,
    this.offset = 50.0,
  });

  @override
  State<SlideFromBottomAnimation> createState() =>
      _SlideFromBottomAnimationState();
}

class _SlideFromBottomAnimationState extends State<SlideFromBottomAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.offset),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Loading spinner personalizado
class CustomLoadingSpinner extends StatefulWidget {
  final Color? color;
  final double size;

  const CustomLoadingSpinner({
    super.key,
    this.color,
    this.size = 24.0,
  });

  @override
  State<CustomLoadingSpinner> createState() => _CustomLoadingSpinnerState();
}

class _CustomLoadingSpinnerState extends State<CustomLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CircularProgressIndicator(
          color: widget.color ?? Theme.of(context).primaryColor,
          strokeWidth: 3.0,
        ),
      ),
    );
  }
}