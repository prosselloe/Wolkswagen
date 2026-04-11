import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volkswagen/providers/model_provider.dart';
import '../l10n/app_localizations.dart';

class ChassisSearchDialog extends StatefulWidget {
  const ChassisSearchDialog({super.key});

  @override
  State<ChassisSearchDialog> createState() => _ChassisSearchDialogState();
}

class _ChassisSearchDialogState extends State<ChassisSearchDialog> {
  final _chassisNumberController = TextEditingController();
  Map<String, dynamic>? _searchResultData;
  String? _errorText;

  void _searchChassis() {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);
    final result = modelProvider.searchByChassis(_chassisNumberController.text.trim());

    if (result.containsKey('error')) {
      setState(() {
        _searchResultData = null;
        _errorText = result['error'];
      });
    } else {
      setState(() {
        _searchResultData = result;
        _errorText = null;
      });
    }
  }

  void _showChassisInformationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.vinInfoTitle),
        content: SingleChildScrollView(
          child: Text(l10n.vinInfoContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.vinInfoCloseButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l10n.chassisSearchDialogTitle),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showChassisInformationDialog(context),
            tooltip: l10n.chassisSearchDialogInfoTooltip,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chassisSearchDialogSubtitle,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _chassisNumberController,
              decoration: InputDecoration(
                hintText: l10n.chassisSearchDialogHint,
                errorText: _errorText,
              ),
              keyboardType: TextInputType.number,
            ),
            if (_searchResultData != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  children: _searchResultData!.entries.map((entry) {
                    final bool isModelLink = entry.key == l10n.chassisSearchDialogModel;
                    final bool isIdField = entry.key == 'id';

                    if (isIdField) return Container();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: isModelLink
                                ? GestureDetector(
                                    onTap: () {
                                      final modelName = _searchResultData![l10n.chassisSearchDialogModel];
                                      Navigator.of(context).pop();
                                      Provider.of<ModelProvider>(context, listen: false).search(modelName);
                                    },
                                    child: Text(
                                      '${entry.value}',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                : Text(
                                    '${entry.value}',
                                  ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.chassisSearchDialogCloseButton),
        ),
        ElevatedButton(
          onPressed: _searchChassis,
          child: Text(l10n.chassisSearchDialogSearchButton),
        ),
      ],
    );
  }
}
