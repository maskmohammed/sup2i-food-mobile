import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/auth_scope.dart';
import '../../../core/error/api_codes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Final mandatory login presentation.
///
/// No registration and no social login are intentionally exposed.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _rememberedEmailKey = 'sup2i_food_remembered_email';
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  Future<void> _restoreRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_rememberedEmailKey);

    if (!mounted || email == null || email.isEmpty) return;

    _emailController.text = email;
    setState(() => _rememberMe = true);
  }

  Future<void> _persistRememberedEmail(String email, bool remember) async {
    final prefs = await SharedPreferences.getInstance();

    if (remember) {
      await prefs.setString(_rememberedEmailKey, email);
      return;
    }

    await prefs.remove(_rememberedEmailKey);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.of(context, listen: false);
    final loc = AppLocalizations.of(context);

    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final remember = _rememberMe;

    final ok = await auth.login(email, _passwordController.text);

    if (ok) {
      await _persistRememberedEmail(email, remember);

      if (!mounted) return;

      setState(() => _loading = false);
      return;
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
      _error = loc.errorMessage(auth.errorCode ?? ApiCodes.internalError);
    });
  }

  String? _validateEmail(String? value) {
    final loc = AppLocalizations.of(context);
    final email = value?.trim() ?? '';

    if (email.isEmpty) return loc.loginEmailRequired;

    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : loc.loginEmailInvalid;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return AppLocalizations.of(context).loginPasswordRequired;
    }
    return null;
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pour rÃ©initialiser votre mot de passe, contactez lâ€™administration SUP2I.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      key: const Key('login_screen'),
      backgroundColor: AppColors.neutral0,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 46,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const _LoginHero(),
                    const SizedBox(height: 28),
                    Text(
                      'Bon retour !',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous pour accÃ©der Ã  votre espace SUP2I FOOD.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          TextFormField(
                            key: const Key('login_email'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            enabled: !_loading,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: loc.loginEmailHint,
                              prefixIcon: const Icon(Icons.mail_outline),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const Key('login_password'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_loading,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              hintText: loc.loginPasswordHint,
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: _loading
                                    ? null
                                    : () {
                                        setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        );
                                      },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                tooltip: _obscurePassword
                                    ? loc.loginShowPassword
                                    : loc.loginHidePassword,
                              ),
                            ),
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 34,
                                height: 34,
                                child: Checkbox(
                                  key: const Key('login_remember'),
                                  value: _rememberMe,
                                  activeColor: AppColors.blue600,
                                  onChanged: _loading
                                      ? null
                                      : (value) {
                                          setState(
                                            () => _rememberMe = value ?? false,
                                          );
                                        },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Se souvenir de moi',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              TextButton(
                                key: const Key('login_forgot_password'),
                                onPressed: _loading ? null : _forgotPassword,
                                child: const Text('Mot de passe oubliÃ© ?'),
                              ),
                            ],
                          ),
                          if (_error != null) ...<Widget>[
                            const SizedBox(height: 10),
                            _InlineError(message: _error!),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              key: const Key('login_submit'),
                              onPressed: _loading ? null : _submit,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                child: _loading
                                    ? const SizedBox(
                                        key: ValueKey('login_loading'),
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: AppColors.neutral0,
                                        ),
                                      )
                                    : Text(
                                        loc.loginSubmit,
                                        key: const ValueKey('login_label'),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Votre compte Ã©tudiant est fourni par lâ€™administration.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.navy900, AppColors.blue600],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F161B5C),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -30,
            bottom: -60,
            child: Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                color: AppColors.pink600,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 6,
            child: SizedBox(
              width: 160,
              height: 190,
              child: CustomPaint(painter: _ChefMascotPainter()),
            ),
          ),
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              width: 88,
              height: 88,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Image.asset(
                'assets/images/sup2i_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.pink600,
                    size: 48,
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 26,
            right: 154,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bien manger.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.neutral0,
                  ),
                ),
                Text(
                  'Mieux Ã©tudier.',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppColors.pink600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight original in-app chef illustration.
///
/// It is intentionally generic and brand-owned: large friendly chef,
/// moustache, toque, pink scarf and navy apron. A final high-resolution
/// mascot asset can replace this painter later without changing the layout.
class _ChefMascotPainter extends CustomPainter {
  const _ChefMascotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final skin = Paint()..color = const Color(0xFFF1B38E);
    final white = Paint()..color = AppColors.neutral0;
    final navy = Paint()..color = AppColors.navy900;
    final pink = Paint()..color = AppColors.pink600;
    final dark = Paint()..color = const Color(0xFF3A241D);

    final center = Offset(size.width * 0.55, size.height * 0.47);

    canvas.drawCircle(Offset(center.dx - 23, center.dy - 60), 31, white);
    canvas.drawCircle(Offset(center.dx + 9, center.dy - 68), 36, white);
    canvas.drawCircle(Offset(center.dx + 41, center.dy - 57), 30, white);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 8, center.dy - 35),
          width: 84,
          height: 44,
        ),
        const Radius.circular(18),
      ),
      white,
    );

    canvas.drawOval(
      Rect.fromCenter(center: center, width: 96, height: 112),
      skin,
    );

    canvas.drawCircle(Offset(center.dx - 18, center.dy - 8), 4, dark);
    canvas.drawCircle(Offset(center.dx + 22, center.dy - 8), 4, dark);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 11, center.dy + 14),
        width: 34,
        height: 13,
      ),
      dark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 17, center.dy + 14),
        width: 34,
        height: 13,
      ),
      dark,
    );

    final smile = Paint()
      ..color = const Color(0xFF8C2A2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx + 4, center.dy + 24),
        width: 38,
        height: 22,
      ),
      0.15,
      2.75,
      false,
      smile,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 6, center.dy + 93),
        width: 118,
        height: 112,
      ),
      white,
    );

    final scarfPath = Path()
      ..moveTo(center.dx - 39, center.dy + 54)
      ..lineTo(center.dx + 48, center.dy + 54)
      ..lineTo(center.dx + 24, center.dy + 80)
      ..lineTo(center.dx - 15, center.dy + 76)
      ..close();
    canvas.drawPath(scarfPath, pink);

    final apronPath = Path()
      ..moveTo(center.dx - 34, center.dy + 78)
      ..lineTo(center.dx + 43, center.dy + 78)
      ..lineTo(center.dx + 56, size.height)
      ..lineTo(center.dx - 48, size.height)
      ..close();
    canvas.drawPath(apronPath, navy);

    canvas.drawCircle(Offset(center.dx + 5, center.dy + 114), 13, pink);

    final hand = Paint()..color = skin.color;
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.52), 18, hand);
    final arm = Paint()
      ..color = white.color
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx + 44, center.dy + 74),
      Offset(size.width * 0.82, size.height * 0.55),
      arm,
    );

    final gesture = Paint()
      ..color = skin.color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final handX = size.width * 0.86;
    final handY = size.height * 0.52;
    canvas.drawLine(
      Offset(handX, handY - 4),
      Offset(handX + 6, handY - 27),
      gesture,
    );
    canvas.drawLine(
      Offset(handX + 3, handY - 2),
      Offset(handX + 20, handY - 20),
      gesture,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
