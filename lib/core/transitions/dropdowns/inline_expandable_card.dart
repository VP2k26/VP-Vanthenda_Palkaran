import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../transition_utils.dart';

/// Type 1 Dropdown: Reusable Inline Accordion Card with smooth height expansion & rotating chevron
class InlineExpandableCard extends StatefulWidget {
  final Widget header;
  final Widget expandedContent;
  final bool initialExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  const InlineExpandableCard({
    super.key,
    required this.header,
    required this.expandedContent,
    this.initialExpanded = false,
    this.onExpansionChanged,
    this.padding = const EdgeInsets.all(14),
    this.backgroundColor = const Color(0xCCFAF6EE),
    this.borderColor = const Color(0x334A2E18),
    this.borderRadius = 18.0,
  });

  @override
  State<InlineExpandableCard> createState() => _InlineExpandableCardState();
}

class _InlineExpandableCardState extends State<InlineExpandableCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late final AnimationController _controller;
  late final Animation<double> _iconRotation;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: AppTransitions.normal,
    );

    _iconRotation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppTransitions.unfoldCurve,
      ),
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppTransitions.unfoldCurve,
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor, width: 1.1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header Row (Tap to expand/collapse) ─────────────────────
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(
              padding: widget.padding,
              child: Row(
                children: [
                  Expanded(child: widget.header),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: _iconRotation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _iconRotation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3AB).withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTransitions.darkBrown,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Inline Expanding Body Content ──────────────────────────
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _expandAnimation,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Column(
                children: [
                  const Divider(height: 1, color: Color(0x224A2E18)),
                  Padding(
                    padding: widget.padding,
                    child: widget.expandedContent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
