// Material 3 Expressive building blocks: spring motion and Material shapes.
import 'dart:math' as math;

import 'package:flutter/physics.dart';
import 'package:material_ui/material_ui.dart';

/// Makes the [ElevatedButton]s in [child] Expressive, keeping the ambient
/// button style.
Widget expressiveButtonTheme(BuildContext context, {required Widget child}) {
  return ElevatedButtonTheme(
    data: ElevatedButtonThemeData(
      style: ElevatedButtonTheme.of(context).style,
      variant: StyleVariant.material3Expressive,
    ),
    child: child,
  );
}

/// Springs a value from [initialValue] (or [value]) to [value], and again
/// whenever [value] changes. Jumps when animations are disabled.
class PollSpringValue extends StatefulWidget {
  const PollSpringValue({
    super.key,
    required this.value,
    required this.builder,
    this.initialValue,
    this.spring = Springs.standardDefaultSpatial,
  });

  final double value;
  final double? initialValue;
  final SpringDescription spring;
  final Widget Function(BuildContext context, double value) builder;

  @override
  State<PollSpringValue> createState() => _PollSpringValueState();
}

class _PollSpringValueState extends State<PollSpringValue>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.initialValue ?? widget.value,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _animateTo(widget.value);
    }
  }

  @override
  void didUpdateWidget(PollSpringValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _animateTo(widget.value);
  }

  void _animateTo(double target) {
    if (_controller.value == target && !_controller.isAnimating) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = target;
      return;
    }
    _controller
        .animateWith(
          SpringSimulation(
            widget.spring,
            _controller.value,
            target,
            _controller.velocity,
          ),
        )
        // The simulation stops within a tolerance; land exactly on target.
        .then((_) => _controller.value = target);
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
      builder: (context, _) => widget.builder(context, _controller.value),
    );
  }
}

/// [MaterialShapeBorder]s morph when lerped; snap to the ends so settled
/// borders compare equal to [a] or [b].
OutlinedBorder _morph(MaterialShapeBorder a, MaterialShapeBorder b, double t) {
  if (t <= 0) return a;
  if (t >= 1) return b;
  return ShapeBorder.lerp(a, b, t)! as OutlinedBorder;
}

/// A [MaterialShapes] shape filled with [color], with an optional centered
/// [icon]. Hidden from screen readers unless [semanticLabel] is set.
class PollShapeBadge extends StatelessWidget {
  const PollShapeBadge({
    super.key,
    required this.shape,
    required this.color,
    this.icon,
    this.iconColor,
    this.semanticLabel,
    this.size = 20,
  });

  final RoundedPolygon shape;
  final Color color;
  final IconData? icon;
  final Color? iconColor;
  final String? semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: color,
              shape: MaterialShapeBorder(shape: shape),
            ),
            child: icon == null
                ? null
                : Icon(icon, size: size * 0.6, color: iconColor),
          ),
        ),
      ),
    );
  }
}

/// Multi-select indicator: an outlined circle that morphs into a filled
/// cookie with a check when [selected].
class PollSelectionIndicator extends StatelessWidget {
  const PollSelectionIndicator({
    super.key,
    required this.selected,
    required this.color,
    required this.checkColor,
  });

  static final RoundedPolygon unselectedShape = MaterialShapes.circle;
  static final RoundedPolygon selectedShape = MaterialShapes.cookie9Sided;
  static const double _size = 22;

  final bool selected;
  final Color color;
  final Color checkColor;

  @override
  Widget build(BuildContext context) {
    return PollSpringValue(
      value: selected ? 1 : 0,
      spring: Springs.standardFastSpatial,
      builder: (context, value) {
        final t = value.clamp(0.0, 1.0);
        final shape = _morph(
          MaterialShapeBorder(
            shape: unselectedShape,
            side: BorderSide(color: color, width: 2),
          ),
          MaterialShapeBorder(shape: selectedShape),
          t,
        );
        return SizedBox.square(
          dimension: _size,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: color.withValues(alpha: color.a * t),
              shape: shape,
            ),
            child: Opacity(
              opacity: t,
              child: Icon(Icons.check, size: _size * 0.65, color: checkColor),
            ),
          ),
        );
      },
    );
  }
}

/// A Material 3 Expressive style loading indicator in the ambient [IconTheme]
/// color that spins while morphing through [MaterialShapes]. Shows a still
/// shape when animations are disabled.
class PollShapeLoader extends StatefulWidget {
  const PollShapeLoader({super.key});

  static const double _size = 20;

  static final List<RoundedPolygon> shapes = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
  ];

  static const Duration _perShape = Duration(milliseconds: 650);

  @override
  State<PollShapeLoader> createState() => _PollShapeLoaderState();
}

class _PollShapeLoaderState extends State<PollShapeLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: PollShapeLoader._perShape * PollShapeLoader.shapes.length,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color!;
    final shapes = PollShapeLoader.shapes;
    return SizedBox.square(
      dimension: PollShapeLoader._size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final position = _controller.value * shapes.length;
          final index = position.floor() % shapes.length;
          // Hold each shape for the first half of its slot, then morph.
          final t = Easing.emphasizedDecelerate.transform(
            ((position - position.floor() - 0.5) * 2).clamp(0.0, 1.0),
          );
          return Transform.rotate(
            angle: _controller.value * 4 * math.pi,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: color,
                shape: _morph(
                  MaterialShapeBorder(shape: shapes[index]),
                  MaterialShapeBorder(
                    shape: shapes[(index + 1) % shapes.length],
                  ),
                  t,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
