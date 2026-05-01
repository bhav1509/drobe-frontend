import 'package:flutter/material.dart';

import '../app_state.dart';

class SignInScreen extends StatefulWidget {
  final bool canContinueAsGuest;

  const SignInScreen({super.key, this.canContinueAsGuest = true});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSigningIn = false;

  Future<void> _signInWithGoogle(AppState appState) async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      await appState.signInWithGoogle();

      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Widget _googleMark() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DROBE'),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'War',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: scheme.onSurfaceVariant,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Drobe',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your wardrobe, styled smarter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: _isSigningIn
                        ? null
                        : () => _signInWithGoogle(appState),
                    icon: _isSigningIn
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF202124),
                            ),
                          )
                        : _googleMark(),
                    label: Text(
                      _isSigningIn ? 'Signing in...' : 'Sign in with Google',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFFF2F3F5),
                      foregroundColor: const Color(0xFF202124),
                      disabledBackgroundColor: const Color(
                        0xFFF2F3F5,
                      ).withValues(alpha: 0.7),
                      disabledForegroundColor: const Color(
                        0xFF202124,
                      ).withValues(alpha: 0.75),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Color(0xFFDADCE0)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (widget.canContinueAsGuest) ...[
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: _isSigningIn ? null : appState.useGuest,
                      child: const Text('Continue as guest'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  static const double _strokeWidth = 3.6;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(rect.deflate(_strokeWidth / 2), -0.05, 1.35, false, stroke);

    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(rect.deflate(_strokeWidth / 2), 1.3, 1.45, false, stroke);

    stroke.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect.deflate(_strokeWidth / 2), 2.75, 1.0, false, stroke);

    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(rect.deflate(_strokeWidth / 2), 3.75, 1.3, false, stroke);

    final centerY = size.height / 2;
    stroke.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * 0.52, centerY),
      Offset(size.width * 0.92, centerY),
      stroke,
    );
    canvas.drawLine(
      Offset(size.width * 0.92, centerY),
      Offset(size.width * 0.82, size.height * 0.66),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
