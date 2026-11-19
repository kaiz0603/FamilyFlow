import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/result.dart';
import 'app_error_text.dart';

/// Full-width primary button that shows a spinner while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    child: busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label),
  );
}

/// Inline error line under a form; renders nothing when [error] is null.
class ErrorLine extends StatelessWidget {
  const ErrorLine(this.error, {super.key});

  final AppError? error;

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (e == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        e.message(AppLocalizations.of(context)),
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

/// Centered, width-limited scrolling column for forms.
class FormPage extends StatelessWidget {
  const FormPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    ),
  );
}
