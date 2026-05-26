import 'package:flutter/material.dart';

class TableColumnData {
  final String name;
  final int flex;

  const TableColumnData({required this.name, this.flex = 1});
}

class SyTable extends StatelessWidget {
  final List<TableColumnData> columns;
  final List<List<Widget>> rows;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry rowPadding;
  final Widget? empty;
  final BorderRadius? borderRadius;
  final double? maxHeight;

  const SyTable({
    super.key,
    required this.columns,
    required this.rows,
    this.headerPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 14,
    ),
    this.rowPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.empty,
    this.borderRadius,
    this.maxHeight = 500,
  }) : assert(columns.length > 0, "Table must contain at least one column");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    for (final row in rows) {
      assert(
        row.length == columns.length,
        "Every row must contain the same number of widgets as columns",
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight!),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: headerPadding,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  borderRadius != null
                      ? BorderRadius.only(
                        topLeft: borderRadius!.topLeft,
                        topRight: borderRadius!.topRight,
                      )
                      : const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                for (final column in columns)
                  Expanded(
                    flex: column.flex,
                    child: Text(
                      column.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          // Empty state
          if (rows.isEmpty)
            Expanded(
              child:
                  empty ??
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
            )
          else
            // Scrollable rows
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  return Container(
                    padding: rowPadding,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: theme.dividerColor.withOpacity(0.1),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        for (int j = 0; j < rows[i].length; j++)
                          Expanded(flex: columns[j].flex, child: rows[i][j]),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
