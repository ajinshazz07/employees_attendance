import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:employees_attendance/bloc/scannerPage/scanner_page_bloc.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/services/local_database_service.dart';
import 'package:employees_attendance/services/qr_service.dart';

class ScannerPageView extends StatefulWidget {
  const ScannerPageView({super.key});

  @override
  State<ScannerPageView> createState() => _ScannerPageViewState();
}

class _ScannerPageViewState extends State<ScannerPageView> {
  MobileScannerController? _scannerController;
  bool _isProcessingCode = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
    );
    context.read<ScannerPageBloc>().add(const ResetScannerStateEvent());
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessingCode) return;
    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;
    if (code != null && code.isNotEmpty) {
      debugPrint('📷 [QR CAMERA DETECTED] Scanned code: $code');
      setState(() => _isProcessingCode = true);
      context.read<ScannerPageBloc>().add(ProcessScannedQrEvent(qrData: code));
    }
  }

  Future<void> _toggleTorch() async {
    try {
      if (_scannerController?.value.isInitialized == true) {
        await _scannerController?.toggleTorch();
      }
    } catch (e) {
      debugPrint('⚠️ Torch toggle error: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      if (_scannerController?.value.isInitialized == true) {
        await _scannerController?.switchCamera();
      }
    } catch (e) {
      debugPrint('⚠️ Camera switch error: $e');
    }
  }

  /// Facilitates emulator / simulator testing without a physical camera
  Future<void> _simulateDemoScan() async {
    debugPrint('👆 [USER TAP] Test Scan (Simulator Demo) button tapped in Scanner AppBar');
    if (_isProcessingCode) return;
    final dbService = LocalDatabaseService();
    final qrService = QrService();

    final activeSession = await dbService.getLatestActiveQrSession();
    String qrData;
    if (activeSession != null) {
      qrData = qrService.encodeQrData(activeSession);
      debugPrint('ℹ️ [SIMULATOR] Using existing active QR session: ${activeSession.sessionId}');
    } else {
      final session = qrService.generateQrSession('ADM001');
      await dbService.insertQrSession(session);
      qrData = qrService.encodeQrData(session);
      debugPrint('ℹ️ [SIMULATOR] Auto-generated fresh test session: ${session.sessionId}');
    }

    setState(() => _isProcessingCode = true);
    if (mounted) {
      context
          .read<ScannerPageBloc>()
          .add(ProcessScannedQrEvent(qrData: qrData));
    }
  }

  void _showResultDialog({
    required BuildContext context,
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: (isSuccess ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.close_rounded,
                  color: isSuccess ? AppColors.success : AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                if (isSuccess) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } else {
                  if (mounted) {
                    setState(() => _isProcessingCode = false);
                    context
                        .read<ScannerPageBloc>()
                        .add(const ResetScannerStateEvent());
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Scan QR',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
            tooltip: 'Toggle Flashlight',
            onPressed: _toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 20),
            tooltip: 'Switch Camera',
            onPressed: _switchCamera,
          ),
          TextButton.icon(
            onPressed: _simulateDemoScan,
            icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Test Scan',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<ScannerPageBloc, ScannerPageState>(
        listener: (context, state) {
          if (!mounted) return;
          if (state is ScannerPageSuccess) {
            _showResultDialog(
              context: context,
              isSuccess: true,
              title: state.isCheckIn ? 'Check-In Success' : 'Check-Out Success',
              message: state.message,
            );
          } else if (state is ScannerPageFailure) {
            _showResultDialog(
              context: context,
              isSuccess: false,
              title: 'Verification Failed',
              message: state.errorMessage,
            );
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Live Camera Feed
            if (_scannerController != null)
              MobileScanner(
                controller: _scannerController!,
                onDetect: _onBarcodeDetected,
                errorBuilder: (context, error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_outlined,
                              size: 54, color: Colors.white54),
                          const SizedBox(height: 16),
                          const Text(
                            'Camera Unavailable',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.errorDetails?.message ??
                                'Please grant camera permission in settings or tap "Test Scan" above to test on simulator.',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              _scannerController?.start();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Minimalist Viewfinder Reticle
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                ),
              ),
            ),

            // Instructions and Location Pill
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.success, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Office Geofence Active (500m)',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Align QR code inside the viewfinder frame',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Loading indicator when processing
            BlocBuilder<ScannerPageBloc, ScannerPageState>(
              builder: (context, state) {
                if (state is ScannerPageProcessing) {
                  return Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
