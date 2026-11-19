import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

/// Stand-in for a tab until its feature milestone replaces it.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(AppLocalizations.of(context).comingSoon)),
    );
  }
}
