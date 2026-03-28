import 'package:flutter/material.dart';
import 'package:app_financeflix/models/app_transaction.dart';
import 'package:app_financeflix/services/finance_service.dart';
import 'package:app_financeflix/services/settings_service.dart';
import 'add_transaction_screen.dart';
import 'mail_inbox_screen.dart';
import 'transaction_detail_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  final FinanceService service;
  final SettingsService settingsService;
  final int accountId;

  const AccountDetailScreen({
    super.key,
    required this.service,
    required this.settingsService,
    required this.accountId,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  void initState() {
    super.initState();
    widget.service.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.service,
      builder: (context, _) {
        final account = widget.service.accountById(widget.accountId);
        if (account == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Account not found')),
          );
        }
        final transactions = widget.service.transactionsFor(widget.accountId);
        return Scaffold(
          appBar: AppBar(
            title: Text(account.name),
            actions: [
              ListenableBuilder(
                listenable: widget.settingsService,
                builder: (context, _) {
                  if (!widget.settingsService.mailInboxEnabled) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.mail_outlined),
                    tooltip: 'Mail Inboxes',
                    onPressed: () {
                      if (widget.service.apiClient == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MailInboxScreen(
                            apiClient: widget.service.apiClient!,
                            accountId: widget.accountId,
                            accountName: account.name,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                widget.service.fetchAccounts(),
                widget.service.fetchTransactions(),
              ]);
            },
            child: widget.service.loadingTransactions && transactions.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : widget.service.transactionsError != null && transactions.isEmpty
                    ? _buildErrorState(context)
                    : CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildBalanceCard(
                                context, account.balance, transactions),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Transactions',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${transactions.length}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (transactions.isEmpty)
                            SliverFillRemaining(
                              child: _buildEmptyTransactions(context),
                            )
                          else
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildTransactionTile(
                                    context, transactions[index]),
                                childCount: transactions.length,
                              ),
                            ),
                        ],
                      ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTransactionScreen(
                    service: widget.service,
                    accountId: widget.accountId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Transaction'),
          ),
        );
      },
    );
  }

  List<double> _buildBalanceHistory(
      double currentBalance, List<AppTransaction> transactions) {
    final now = DateTime.now();
    final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

    final recent = transactions
        .where((t) => t.date.isAfter(threeMonthsAgo))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalRecent = recent.fold<double>(0, (sum, t) => sum + t.amount);
    final startBalance = currentBalance - totalRecent;

    final totalDays = now.difference(threeMonthsAgo).inDays;
    if (totalDays <= 0) return [currentBalance];

    final points = <double>[];
    var runningBalance = startBalance;
    var txIndex = 0;

    for (var day = 0; day <= totalDays; day++) {
      final date = threeMonthsAgo.add(Duration(days: day));
      while (txIndex < recent.length &&
          (recent[txIndex].date.year < date.year ||
              (recent[txIndex].date.year == date.year &&
                  recent[txIndex].date.month < date.month) ||
              (recent[txIndex].date.year == date.year &&
                  recent[txIndex].date.month == date.month &&
                  recent[txIndex].date.day <= date.day))) {
        runningBalance += recent[txIndex].amount;
        txIndex++;
      }
      points.add(runningBalance);
    }

    return points;
  }

  Widget _buildBalanceCard(BuildContext context, double balance,
      List<AppTransaction> transactions) {
    final colorScheme = Theme.of(context).colorScheme;
    final balanceHistory = _buildBalanceHistory(balance, transactions);
    final lineColor = balance >= 0 ? colorScheme.primary : colorScheme.error;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (balanceHistory.length >= 2)
            Positioned.fill(
              child: CustomPaint(
                painter: _BalanceChartPainter(
                  dataPoints: balanceHistory,
                  lineColor: lineColor,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Balance',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${balance.toStringAsFixed(2)} \u20AC',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: balance >= 0
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            'Could not load transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.service.transactionsError!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => widget.service.fetchTransactions(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, AppTransaction tx) {
    final isPositive = tx.amount >= 0;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(
              service: widget.service,
              transactionId: tx.id,
              accountId: widget.accountId,
            ),
          ),
        );
      },
      leading: CircleAvatar(
        backgroundColor: isPositive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        child: Icon(
          tx.category.icon,
          color: isPositive ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        tx.description ?? tx.category.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${tx.category.label} \u2022 '
        '${tx.date.day.toString().padLeft(2, '0')}.'
        '${tx.date.month.toString().padLeft(2, '0')}.'
        '${tx.date.year}',
        style: TextStyle(color: colorScheme.outline),
      ),
      trailing: Text(
        '${isPositive ? '+' : ''}${tx.amount.toStringAsFixed(2)} \u20AC',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: isPositive ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

class _BalanceChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  _BalanceChartPainter({required this.dataPoints, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.length < 2) return;

    final minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final effectiveRange = range == 0 ? 1.0 : range;

    final padding = size.height * 0.15;
    final chartHeight = size.height - padding * 2;

    double yFor(double value) {
      return padding + chartHeight - ((value - minVal) / effectiveRange) * chartHeight;
    }

    final path = Path();
    final stepX = size.width / (dataPoints.length - 1);

    path.moveTo(0, yFor(dataPoints[0]));
    for (var i = 1; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = yFor(dataPoints[i]);
      final prevX = (i - 1) * stepX;
      final prevY = yFor(dataPoints[i - 1]);
      final cx = (prevX + x) / 2;
      path.cubicTo(cx, prevY, cx, y, x, y);
    }

    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.15),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _BalanceChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.lineColor != lineColor;
  }
}
