import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:volkswagen/services/vin_service.dart';
import '../l10n/app_localizations.dart';

class VinDecoderDialog extends StatefulWidget {
  const VinDecoderDialog({super.key});

  @override
  State<VinDecoderDialog> createState() => _VinDecoderDialogState();
}

class _VinDecoderDialogState extends State<VinDecoderDialog> {
  final _vinController = TextEditingController();
  String? _errorText;
  Map<String, String>? _decodedData;

  void _decodeVin() {
    final l10n = AppLocalizations.of(context)!;
    final vin = _vinController.text.trim().toUpperCase();
    if (vin.length != 17) {
      setState(() {
        _errorText = l10n.vinDecoderDialogError17Chars;
        _decodedData = null;
      });
      return;
    }

    final wmi = vin.substring(0, 3);
    final vds = vin.substring(3, 9);
    final vis = vin.substring(9);
    final plantCode = vin[10];
    final sequenceNumber = vin.substring(11);

    final country = VinService.decodeWmi(wmi);
    final modelResult = VinService.decodeVin(vin);
    final plant = VinService.getPlantFromCode(plantCode, modelResult?.modelYear);

    setState(() {
      if (modelResult != null) {
        _decodedData = {
          l10n.vinDecoderDialogVehicleModel: modelResult.modelName,
          l10n.vinDecoderDialogModelYear: modelResult.modelYear.toString(),
          l10n.vinDecoderDialogCountry: country ?? l10n.vinDecoderDialogUnknown,
          l10n.vinDecoderDialogAssemblyPlant: plant ?? l10n.vinDecoderDialogUnknown,
          l10n.vinDecoderDialogManufacturer: 'Volkswagen',
          l10n.vinDecoderDialogSequenceNumber: sequenceNumber,
          l10n.vinDecoderDialogWMI: wmi,
          l10n.vinDecoderDialogVDS: vds,
          l10n.vinDecoderDialogVIS: vis,
        };
        _errorText = null;
      } else {
        _decodedData = null;
        _errorText = l10n.vinDecoderDialogErrorDecoding;
      }
    });
  }

  void _launchSearch(String model, String year) async {
    final l10n = AppLocalizations.of(context)!;
    final query = Uri.encodeComponent('$model $year');
    final url = Uri.parse('https://www.google.com/search?q=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.couldNotOpenLink)),
      );
    }
  }

  void _showVinInformationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.vinInfoDialogTitle),
        content: SingleChildScrollView(
          child: Text(l10n.vinInfoDialogContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.vinDecoderDialogCloseButton),
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
        Text(l10n.vinDecoderDialogTitle),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showVinInformationDialog(context),
          tooltip: l10n.vinDecoderDialogInfoTooltip,
        ),
      ],
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.vinDecoderDialogSubtitle,
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _vinController,
            decoration: InputDecoration(
              hintText: l10n.vinDecoderDialogHint,
              errorText: _errorText,
            ),
          ),
          if (_decodedData != null)
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _decodedData!.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (entry.key == l10n.vinDecoderDialogVehicleModel)
                            TextSpan(
                              text: entry.value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  _launchSearch(entry.value, _decodedData![l10n.vinDecoderDialogModelYear]!);
                                },
                            )
                          else
                            TextSpan(text: entry.value),
                        ],
                      ),
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
        child: Text(l10n.vinDecoderDialogCloseButton),
      ),
      ElevatedButton(
        onPressed: _decodeVin,
        child: Text(l10n.vinDecoderDialogDecodeButton),
      ),
    ],
  );
}
}
