import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../../app/router.dart';
import '../../../../domain/assessment/compare.dart';
import '../../../../domain/assessment/scoring.dart';
import '../../../../domain/models/assessment.dart';
import '../../../../domain/models/family.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/assessment_labels.dart';
import '../view_models/compare_view_model.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<CompareViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text(l.tabCompare)),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : !vm.hasFamily
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l.compareNoFamily, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final c in vm.cards) _ParentCard(c),
                if (!vm.isParent && vm.cards.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l.compareChildNone),
                  ),
                for (final p in vm.unratedParents)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: FilledButton.tonal(
                      onPressed: () =>
                          context.push(Routes.assessment(p.uid, p.displayName)),
                      child: Text(l.compareRateParent(p.displayName)),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// One rater's line or point: Self, or a Child.
typedef _Series = ({String raterId, String name, Color color, bool isSelf});

const _childColors = [
  Colors.deepOrange,
  Colors.purple,
  Colors.pink,
  Colors.indigo,
  Colors.brown,
];

List<_Series> _series(
  BuildContext context,
  ParentComparison c,
  List<({String uid, String name})> children,
) {
  final l = AppLocalizations.of(context);
  return [
    (
      raterId: c.parent.uid,
      name: l.compareSelfName(c.parent.displayName),
      color: Theme.of(context).colorScheme.primary,
      isSelf: true,
    ),
    for (final (i, ch) in children.indexed)
      (
        raterId: ch.uid,
        name: ch.name,
        color: _childColors[i % _childColors.length],
        isSelf: false,
      ),
  ];
}

class _ParentCard extends StatelessWidget {
  const _ParentCard(this.c);

  final ParentComparison c;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.read<CompareViewModel>();
    final theme = Theme.of(context);
    final raters = vm.isParent
        ? [for (final ch in vm.children) (uid: ch.uid, name: ch.displayName)]
        : [(uid: vm.me!.uid, name: vm.me!.displayName)];
    final series = _series(context, c, raters);
    final points = [
      if (c.self case final s?) (series.first, s),
      for (final v in c.views)
        (series.firstWhere((s) => s.raterId == v.child.uid), v.view),
    ];
    final self = c.self;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(c.parent.displayName, style: theme.textTheme.titleLarge),
            _QuadrantChart(points),
            _Legend([for (final p in points) p.$1]),
            if (self != null)
              for (final v in c.views) ..._gapLines(l, self, v),
            if (vm.isParent && self == null) ...[
              Text(l.compareInviteSelf),
              FilledButton.tonal(
                onPressed: () => context.push(
                  Routes.assessment(vm.me!.uid, vm.me!.displayName),
                ),
                child: Text(l.takeIt),
              ),
            ],
            if (vm.isParent && c.views.isEmpty)
              Text(
                vm.children.isEmpty
                    ? l.compareNoChildren
                    : l.compareInviteChildren,
              ),
            if (!vm.isParent && self == null)
              Text(l.compareParentNoSelf(c.parent.displayName)),
            if (c.history.isNotEmpty) ...[
              const Divider(),
              Text(l.historyTitle, style: theme.textTheme.titleMedium),
              for (final d in Dimension.values)
                _HistoryChart(dimension: d, history: c.history, series: series),
              if (c.history.map((a) => a.majorVersion).toSet().length > 1)
                Text(l.historyNotComparable, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _gapLines(
    AppLocalizations l,
    Assessment self,
    ({Member child, Assessment view}) v,
  ) {
    final g = gap(self, v.view);
    return [
      for (final (dim, value) in [
        ('warmth', g.warmth),
        ('demandingness', g.demandingness),
      ])
        Text(switch (gapBand(value)) {
          GapBand.same => l.gapSame(
            v.child.displayName,
            c.parent.displayName,
            dim,
          ),
          final band => l.gapDiff(
            v.child.displayName,
            c.parent.displayName,
            dim,
            band == GapBand.large ? 'large' : 'some',
            value > 0 ? 'more' : 'less',
          ),
        }),
    ];
  }
}

class _QuadrantChart extends StatelessWidget {
  const _QuadrantChart(this.points);

  final List<(_Series, Assessment)> points;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = [
      l.chartQuadrantLabel,
      if (points.isEmpty) l.chartEmpty,
      for (final (s, a) in points)
        l.chartPoint(s.name, a.warmth, a.demandingness, a.style.label(l)),
    ].join(' ');
    Widget corner(Alignment at, ParentingStyle style) => Align(
      alignment: at,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          style.label(l),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
    return Semantics(
      container: true,
      label: summary,
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 1.1,
          child: Stack(
            children: [
              ScatterChart(
                ScatterChartData(
                  minX: 0,
                  maxX: 100,
                  minY: 0,
                  maxY: 100,
                  scatterSpots: [
                    for (final (s, a) in points)
                      ScatterSpot(
                        a.warmth.toDouble(),
                        a.demandingness.toDouble(),
                        dotPainter: s.isSelf
                            ? FlDotSquarePainter(color: s.color, size: 14)
                            : FlDotCirclePainter(color: s.color, radius: 7),
                      ),
                  ],
                  gridData: FlGridData(
                    horizontalInterval: 50,
                    verticalInterval: 50,
                    checkToShowHorizontalLine: (v) => v == cutoff,
                    checkToShowVerticalLine: (v) => v == cutoff,
                  ),
                  borderData: FlBorderData(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  scatterTouchData: ScatterTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text(l.dimWarmth),
                      sideTitles: const SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(l.dimDemandingness),
                      sideTitles: const SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                ),
              ),
              // Quadrant names inside the plot area.
              // shortcut: insets = axis name (16) + side titles reserved size.
              Positioned.fill(
                left: 56,
                bottom: 40,
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      corner(Alignment.topRight, ParentingStyle.authoritative),
                      corner(Alignment.topLeft, ParentingStyle.authoritarian),
                      corner(Alignment.bottomRight, ParentingStyle.permissive),
                      corner(Alignment.bottomLeft, ParentingStyle.neglectful),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.series);

  final List<_Series> series;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final s in series)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: s.color,
                  shape: s.isSelf ? BoxShape.rectangle : BoxShape.circle,
                ),
              ),
              Text(s.name),
            ],
          ),
      ],
    ),
  );
}

class _HistoryChart extends StatelessWidget {
  const _HistoryChart({
    required this.dimension,
    required this.history,
    required this.series,
  });

  final Dimension dimension;
  final List<Assessment> history; // oldest first
  final List<_Series> series;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t0 = history.first.createdAt;
    double x(Assessment a) => a.createdAt.difference(t0).inHours / 24;
    int value(Assessment a) =>
        dimension == Dimension.warmth ? a.warmth : a.demandingness;
    final lines = [
      for (final s in series)
        if (history.where((a) => a.raterId == s.raterId).toList() case final pts
            when pts.isNotEmpty)
          (s, pts),
    ];
    final dimName = dimension == Dimension.warmth
        ? l.dimWarmth
        : l.dimDemandingness;
    final summary = l.historySummary(
      dimName,
      [for (final (s, pts) in lines) '${s.name}: ${pts.map(value).join(', ')}.']
          .join(' '),
    );
    // A dashed line where each new major Content Version starts.
    final versionStarts = [
      for (final (i, a) in history.indexed)
        if (i > 0 && a.majorVersion != history[i - 1].majorVersion) a,
    ];
    final maxX = history.map(x).fold(1.0, (m, v) => v > m ? v : m);

    return Semantics(
      container: true,
      label: summary,
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dimName, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12), // room for the top "100" label
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: 100,
                  lineTouchData: const LineTouchData(enabled: false),
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 50,
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    bottomTitles: AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  extraLinesData: ExtraLinesData(
                    verticalLines: [
                      for (final a in versionStarts)
                        VerticalLine(
                          x: x(a),
                          dashArray: const [4, 4],
                          color: Theme.of(context).colorScheme.outline,
                          label: VerticalLineLabel(
                            show: true,
                            labelResolver: (_) =>
                                l.historyVersion(a.majorVersion),
                          ),
                        ),
                    ],
                  ),
                  lineBarsData: [
                    for (final (s, pts) in lines)
                      LineChartBarData(
                        spots: [
                          for (final a in pts)
                            FlSpot(x(a), value(a).toDouble()),
                        ],
                        color: s.color,
                        barWidth: 2,
                        dotData: const FlDotData(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
