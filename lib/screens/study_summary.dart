import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_constants.dart';
import '../providers/study_provider.dart';
import '../routing/app_routes.dart';
import '../widgets/lottie_slot.dart';
import '../widgets/pill_button.dart';
import 'screen_scaffold.dart';

class StudySummaryScreen extends StatefulWidget {
  const StudySummaryScreen({super.key});

  @override
  State<StudySummaryScreen> createState() => _StudySummaryScreenState();
}

class _StudySummaryScreenState extends State<StudySummaryScreen> {
  bool _saved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_saved) return;
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      final String? mockId = arguments['mockId'] as String?;
      if (mockId != null) {
        _saved = true;
        context.read<StudyProvider>().saveMockExamScore(mockId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    final String title = arguments is Map<String, dynamic>
        ? arguments['title'] as String? ?? 'Study summary'
        : 'Study summary';
    final double score = arguments is Map<String, dynamic>
        ? (arguments['score'] as num?)?.toDouble() ?? 0
        : 0;

    return ScreenScaffold(
      title: 'Study summary',
      subtitle: title,
      showBack: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const LottieSlot(
            asset: AppConstants.lottieBookingSuccess,
            height: 150,
            caption: 'Keep going',
          ),
          const SizedBox(height: 16),
          SectionCard(
            child: Column(
              children: <Widget>[
                Text(
                  '${score.toStringAsFixed(0)} pts',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Your result is saved to this mock exam.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Spacer(),
          PillButton(
            label: 'Back to study studio',
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(AppRoutes.study),
          ),
        ],
      ),
    );
  }
}
