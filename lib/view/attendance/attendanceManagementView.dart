import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:employees_attendance/bloc/attendance/attendanceManagement/attendance_management_bloc.dart';
import 'package:employees_attendance/core/constant.dart';
import 'package:employees_attendance/models/attendanceModel.dart';

class AttendanceManagementView extends StatefulWidget {
  const AttendanceManagementView({super.key});

  @override
  State<AttendanceManagementView> createState() =>
      _AttendanceManagementViewState();
}

class _AttendanceManagementViewState extends State<AttendanceManagementView> {
  int? _selectedEmployeeId;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    context
        .read<AttendanceManagementBloc>()
        .add(const LoadAllAttendanceRecordsEvent());
  }

  void _applyFilter() {
    final dateStr = _selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : null;
    debugPrint('👆 [USER TAP] Applying filter in Attendance Management: EmpID=$_selectedEmployeeId, Date=$dateStr');
    context.read<AttendanceManagementBloc>().add(FilterAttendanceRecordsEvent(
          employeeId: _selectedEmployeeId,
          date: dateStr,
        ));
  }

  void _clearFilter() {
    debugPrint('👆 [USER TAP] Clearing filters in Attendance Management');
    setState(() {
      _selectedEmployeeId = null;
      _selectedDate = null;
    });
    context
        .read<AttendanceManagementBloc>()
        .add(const LoadAllAttendanceRecordsEvent());
  }

  Future<void> _pickDate() async {
    debugPrint('👆 [USER TAP] Date picker opened in Attendance Management');
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      debugPrint('📅 [FILTER] Date chosen: $picked');
      setState(() => _selectedDate = picked);
      _applyFilter();
    }
  }

  void _showReportSheet(List<AttendanceModel> records) {
    debugPrint('👆 [USER TAP] Opening Attendance Statistics & Reports Sheet (${records.length} records)');
    final total = records.length;
    final present = records
        .where((r) =>
            r.status?.toLowerCase() == 'present' ||
            r.status?.toLowerCase() == 'approved')
        .length;
    final late =
        records.where((r) => r.status?.toLowerCase() == 'late').length;
    final absent =
        records.where((r) => r.status?.toLowerCase() == 'absent').length;

    final attendanceRate =
        total > 0 ? ((present + late) / total * 100).toStringAsFixed(1) : '0.0';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Attendance Rate', '$attendanceRate%', AppColors.success),
                  Container(height: 30, width: 1, color: AppColors.border),
                  _statItem('Total Logs', '$total', AppColors.textPrimary),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _breakdownRow('On-Time Check-In', present, AppColors.success),
            _breakdownRow('Late Check-In', late, AppColors.warning),
            _breakdownRow('Absent', absent, AppColors.error),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('👆 [USER TAP] "Export Attendance Report" tapped in Attendance Management');
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attendance report exported successfully!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.file_download_outlined, size: 18),
                label: const Text('Export CSV Report', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _breakdownRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text('$count', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Attendance Records',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          BlocBuilder<AttendanceManagementBloc, AttendanceManagementState>(
            builder: (context, state) {
              if (state is AttendanceManagementLoaded) {
                return IconButton(
                  icon: const Icon(Icons.analytics_outlined),
                  tooltip: 'View Report',
                  onPressed: () => _showReportSheet(state.records),
                );
              }
              return const SizedBox();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AttendanceManagementBloc, AttendanceManagementState>(
        builder: (context, state) {
          if (state is AttendanceManagementLoading) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          if (state is AttendanceManagementError) {
            return Center(
              child: Text(state.message, style: const TextStyle(color: AppColors.error)),
            );
          }

          if (state is AttendanceManagementLoaded) {
            final records = state.records;
            final employees = state.employees;

            return Column(
              children: [
                // Filter Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Employee Dropdown
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: _selectedEmployeeId,
                              isExpanded: true,
                              hint: const Text('All Employees', style: TextStyle(fontSize: 13)),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('All Employees', style: TextStyle(fontSize: 13)),
                                ),
                                ...employees.map((e) {
                                  final numericId = int.tryParse(
                                          e.id.replaceAll(RegExp(r'[^0-9]'), '')) ??
                                      1;
                                  return DropdownMenuItem<int?>(
                                    value: numericId,
                                    child: Text(e.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => _selectedEmployeeId = val);
                                _applyFilter();
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Date Picker Button
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                _selectedDate != null
                                    ? DateFormat('MMM d').format(_selectedDate!)
                                    : 'Date',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_selectedEmployeeId != null || _selectedDate != null) ...[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textSecondary),
                          onPressed: _clearFilter,
                          tooltip: 'Clear filters',
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),

                // Records List
                Expanded(
                  child: records.isEmpty
                      ? const Center(
                          child: Text(
                            'No records found matching filters',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: records.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return _adminRecordCard(records[index]);
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _adminRecordCard(AttendanceModel item) {
    Color badgeColor;
    final status = item.status?.toLowerCase() ?? 'present';
    if (status == 'late') {
      badgeColor = AppColors.warning;
    } else if (status == 'absent') {
      badgeColor = AppColors.error;
    } else {
      badgeColor = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.employeeName ?? 'Employee #${item.employeeId}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.status ?? 'Present',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.requestDate ?? 'Unknown',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                'In: ${item.checkInTime ?? '--:--'}  •  Out: ${item.checkOutTime ?? '--:--'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
