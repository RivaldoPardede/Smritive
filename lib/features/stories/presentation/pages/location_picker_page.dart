import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

/// Full-screen map that lets the user tap to choose a location.
///
/// Returns a [LatLng] result via [context.pop(result)] when the user confirms,
/// or null if they cancel.
///
/// Only reachable from the paid flavor.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedPoint;

  static const LatLng _defaultCenter = LatLng(-6.2088, 106.8456); // Jakarta

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          tooltip: l10n.btn_close,
          onPressed: () => context.pop(null),
        ),
        title: Text(l10n.location_picker_title, style: AppTextStyles.appTitle),
        actions: [
          // Confirm button — enabled only when a point is picked
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _pickedPoint != null
                ? TextButton(
                    key: const ValueKey('confirm'),
                    onPressed: () => context.pop(_pickedPoint),
                    child: Text(
                      l10n.location_picker_confirm,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
        ],
      ),
      body: Column(
        children: [
          // Instruction banner
          Container(
            width: double.infinity,
            color: AppColors.surfaceVariant,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    l10n.location_picker_hint,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Map
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 10,
                onTap: (tapPosition, point) {
                  setState(() => _pickedPoint = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.smritive',
                ),
                if (_pickedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _pickedPoint!,
                        width: 48,
                        height: 48,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.error,
                          size: 48,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Coordinates preview strip
          if (_pickedPoint != null)
            Container(
              width: double.infinity,
              color: AppColors.surfaceVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.my_location,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${_pickedPoint!.latitude.toStringAsFixed(5)}, '
                    '${_pickedPoint!.longitude.toStringAsFixed(5)}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _pickedPoint = null),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(44, 32),
                    ),
                    child: Text(
                      l10n.location_picker_clear,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
