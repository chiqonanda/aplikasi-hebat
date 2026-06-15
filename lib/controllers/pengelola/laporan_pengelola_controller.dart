import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart' as excel;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/services/supabase_service.dart';
import '../../core/services/session_service.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/format_helper.dart';
import '../../app/routes/app_routes.dart';
import '../../models/kategori_model.dart';
import '../../models/sub_kategori_model.dart';
import '../../models/tipe_sampah_model.dart';
import '../../models/jenis_sampah_model.dart';
import '../../models/pengelolaan_sampah_model.dart';

enum JenisLaporan {
  rekapTransaksi,
}

class LaporanPengelolaController extends GetxController {
  final listAllKategori = <KategoriModel>[].obs;
  final listAllSubKategori = <SubKategoriModel>[].obs;
  final listAllJenisSampah = <JenisSampahModel>[].obs;
  final listAllTipeSampah = <TipeSampahModel>[].obs;
  final listNamaNasabah = <String>[].obs;

  final selectedNasabah = Rx<String?>(null);
  final selectedTanggalMulai = Rx<DateTime?>(null);
  final selectedTanggalAkhir = Rx<DateTime?>(null);

  final isLoading = false.obs;
  final isGenerating = false.obs;

  // Data hasil query untuk preview
  final previewData = <PengelolaanSampahModel>[].obs;
  final hasPreview = false.obs;

  String? get _bankSampahId => SessionService.to.activeBankSampahIdOrNull;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    selectedTanggalMulai.value = DateTime(now.year, now.month, 1);
    selectedTanggalAkhir.value = DateTime(now.year, now.month + 1, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bankSampahId == null) {
        Get.offAllNamed(AppRoutes.pilihBankSampah);
        return;
      }
      _fetchMasterData();
      fetchNamaNasabah();
    });
  }

  Future<void> _fetchMasterData() async {
    try {
      final resKategori = await SupabaseService.client
          .from(SupabaseConstants.tableKategoriSampah)
          .select()
          .eq('is_active', true)
          .order('urutan');
      listAllKategori.value = (resKategori as List)
          .map((e) => KategoriModel.fromJson(e))
          .toList();

      final resSubKategori = await SupabaseService.client
          .from(SupabaseConstants.tableSubKategoriSampah)
          .select()
          .eq('is_active', true)
          .order('urutan');
      listAllSubKategori.value = (resSubKategori as List)
          .map((e) => SubKategoriModel.fromJson(e))
          .toList();

      final resTipe = await SupabaseService.client
          .from(SupabaseConstants.tableTipeSampah)
          .select()
          .eq('is_active', true)
          .order('urutan');
      listAllTipeSampah.value = (resTipe as List)
          .map((e) => TipeSampahModel.fromJson(e))
          .toList();

      final resJenis = await SupabaseService.client
          .from(SupabaseConstants.tableJenisSampah)
          .select()
          .eq('is_active', true)
          .order('urutan');
      listAllJenisSampah.value = (resJenis as List)
          .map((e) => JenisSampahModel.fromJson(e))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat master data: $e');
    }
  }

  Future<void> fetchNamaNasabah() async {
    final bankSampahId = _bankSampahId;
    if (bankSampahId == null) return;
    try {
      final data = await SupabaseService.client
          .from(SupabaseConstants.tablePengelolaanSampah)
          .select('nama_nasabah')
          .eq('bank_sampah_id', bankSampahId);

      final names = (data as List)
          .map((e) => e['nama_nasabah'] as String?)
          .where((name) => name != null && name.trim().isNotEmpty)
          .map((name) => name!.trim())
          .toSet()
          .toList();

      names.sort((a, b) => a.compareTo(b));
      listNamaNasabah.value = names;
    } catch (e) {
      debugPrint('ERROR FETCH NASABAH: $e');
    }
  }

  bool get isValid =>
      selectedTanggalMulai.value != null &&
      selectedTanggalAkhir.value != null;

  Future<List<PengelolaanSampahModel>> _fetchDataLaporan() async {
    final bankSampahId = _bankSampahId;
    if (bankSampahId == null) return [];

    var query = SupabaseService.client
        .from(SupabaseConstants.tablePengelolaanSampah)
        .select('''
          *,
          kategori_sampah(*),
          sub_kategori_sampah(*),
          tipe_sampah(*),
          jenis_sampah(*, tipe_sampah(*)),
          satuan(*),
          bank_sampah(*),
          profiles(*)
        ''')
        .eq('bank_sampah_id', bankSampahId)
        .gte(
          'tanggal_pengelolaan',
          FormatHelper.dateToInput(selectedTanggalMulai.value!),
        )
        .lte(
          'tanggal_pengelolaan',
          FormatHelper.dateToInput(selectedTanggalAkhir.value!),
        );

    if (selectedNasabah.value != null && selectedNasabah.value!.isNotEmpty) {
      query = query.eq('nama_nasabah', selectedNasabah.value!);
    }

    final data =
        await query.order('tanggal_pengelolaan', ascending: true);
    return (data as List)
        .map((e) => PengelolaanSampahModel.fromJson(e))
        .toList();
  }

  Future<void> previewLaporan() async {
    if (!isValid) {
      Get.snackbar(
          'Validasi', 'Tentukan periode laporan terlebih dahulu.');
      return;
    }
    isGenerating.value = true;
    try {
      previewData.value = await _fetchDataLaporan();
      hasPreview.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data laporan: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> exportExcel() async {
    if (!isValid) {
      Get.snackbar('Validasi', 'Tentukan periode laporan terlebih dahulu.');
      return;
    }
    isGenerating.value = true;
    try {
      if (listAllKategori.isEmpty) await _fetchMasterData();

      List<PengelolaanSampahModel> data = previewData;
      if (data.isEmpty) data = await _fetchDataLaporan();

      final Set<String> activeNasabahs = data
          .map((e) => e.namaNasabah)
          .where((name) => name != null && name.trim().isNotEmpty)
          .map((name) => name!.trim())
          .toSet();

      final List<String> nasabahKolom = selectedNasabah.value != null && selectedNasabah.value!.isNotEmpty
          ? [selectedNasabah.value!]
          : activeNasabahs.toList();
      nasabahKolom.sort((a, b) => a.compareTo(b));

      var excelFile = excel.Excel.createExcel();
      final defaultSheet = excelFile.sheets.keys.first;

      final mulai = selectedTanggalMulai.value!;
      final akhir = selectedTanggalAkhir.value!;
      final selisihHari = akhir.difference(mulai).inDays;

      final createdSheets = <String>[];

      if (selisihHari <= 31) {
        final label =
            '${FormatHelper.date(mulai)} - ${FormatHelper.date(akhir)}';
        final sheetName = label.length > 31 ? 'Laporan' : label;
        createdSheets.add(sheetName);
        
        excelFile.rename(defaultSheet, sheetName);
        final sheet = excelFile[sheetName];
        _buildSheet(sheet, label, data, nasabahKolom);
      } else {
        final Map<String, List<PengelolaanSampahModel>> perBulan = {};
        for (final item in data) {
          final tgl = item.tanggalPengelolaan;
          final key =
              '${_namaBulan(tgl.month).toUpperCase()} ${tgl.year}';
          perBulan.putIfAbsent(key, () => []);
          perBulan[key]!.add(item);
        }
        
        final entries = perBulan.entries.toList();
        if (entries.isNotEmpty) {
          final firstKey = entries.first.key;
          excelFile.rename(defaultSheet, firstKey);
          
          for (final entry in entries) {
            createdSheets.add(entry.key);
            final sheet = excelFile[entry.key];
            _buildSheet(sheet, entry.key, entry.value, nasabahKolom);
          }
        }
      }

      final sheetsToDelete = excelFile.sheets.keys.where((k) => !createdSheets.contains(k)).toList();
      for (final key in sheetsToDelete) {
        excelFile.delete(key);
      }

      final bytes = excelFile.save();
      if (bytes == null) throw Exception('Gagal membuat byte data Excel.');

      final startStr =
          FormatHelper.dateToInput(mulai).replaceAll('-', '');
      final endStr =
          FormatHelper.dateToInput(akhir).replaceAll('-', '');
      final bsuName = SessionService.to.activeBankSampahNama
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final fileName = 'laporan_sampah_${bsuName}_$startStr-$endStr.xlsx';
      final shareText =
          'Laporan Bank Sampah ${SessionService.to.activeBankSampahNama} ${FormatHelper.date(mulai)} - ${FormatHelper.date(akhir)}';

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: shareText,
      );
      Get.snackbar(
          'Sukses', 'Laporan Excel berhasil diexport dan siap dibagikan.');
    } catch (e) {
      Get.snackbar('Gagal', 'Export Excel gagal: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  void _buildSheet(
    excel.Sheet sheet,
    String labelPeriode,
    List<PengelolaanSampahModel> data,
    List<String> nasabahKolom,
  ) {
    // ── Pivot: jenis_sampah_id → nama_nasabah → jumlah ───────
    final Map<String, Map<String, double>> pivot = {};
    for (final item in data) {
      final jId = item.jenisSampah?.id;
      if (jId == null) continue;
      final nasName = item.namaNasabah ?? '';
      pivot.putIfAbsent(jId, () => {});
      pivot[jId]![nasName] = (pivot[jId]![nasName] ?? 0) + item.jumlah;
    }

    // ── Helper style ────────────────────────────────────────────
    excel.CellStyle styleHeader() => excel.CellStyle(
          bold: true,
          horizontalAlign: excel.HorizontalAlign.Center,
          verticalAlign: excel.VerticalAlign.Center,
          backgroundColorHex: excel.ExcelColor.fromHexString('#D9D9D9'),
          leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        );

    excel.CellStyle styleGroup() => excel.CellStyle(
          bold: true,
          leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        );

    excel.CellStyle styleData() => excel.CellStyle(
          leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        );

    excel.CellStyle styleNumber() => excel.CellStyle(
          horizontalAlign: excel.HorizontalAlign.Center,
          leftBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          rightBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          topBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
          bottomBorder: excel.Border(borderStyle: excel.BorderStyle.Thin),
        );

    void setRowStyle(excel.Sheet s, int rowIdx, int totalCols, excel.CellStyle style) {
      for (int c = 0; c < totalCols; c++) {
        s.cell(excel.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: rowIdx))
            .cellStyle = style;
      }
    }

    final totalCols = nasabahKolom.length + 3; // NO + JENIS SAMPAH + nasabah... + TOTAL
    int rowIdx = 0;

    // ── Baris 1: Judul ──────────────────────────────────────────
    final cellJudul = sheet.cell(
        excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
    cellJudul.value = excel.TextCellValue('LAPORAN SAMPAH BANK SAMPAH ${SessionService.to.activeBankSampahNama.toUpperCase()}');
    cellJudul.cellStyle = excel.CellStyle(bold: true);
    rowIdx++;

    // ── Baris 2: Periode ────────────────────────────────────────
    final cellBulanLabel = sheet.cell(
        excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx));
    cellBulanLabel.value = excel.TextCellValue('BULAN');
    cellBulanLabel.cellStyle = excel.CellStyle(bold: true);

    final cellBulanVal = sheet.cell(
        excel.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx));
    cellBulanVal.value = excel.TextCellValue(': $labelPeriode');
    rowIdx++;

    rowIdx++; // baris kosong

    // ── Baris Header Kolom ──────────────────────────────────────
    final headerRow = rowIdx;
    sheet
        .cell(excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: headerRow))
        .value = excel.TextCellValue('NO');
    sheet
        .cell(excel.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: headerRow))
        .value = excel.TextCellValue('JENIS SAMPAH');
    for (int i = 0; i < nasabahKolom.length; i++) {
      sheet
          .cell(excel.CellIndex.indexByColumnRow(
              columnIndex: i + 2, rowIndex: headerRow))
          .value = excel.TextCellValue(nasabahKolom[i]);
    }
    sheet
        .cell(excel.CellIndex.indexByColumnRow(
            columnIndex: nasabahKolom.length + 2, rowIndex: headerRow))
        .value = excel.TextCellValue('TOTAL');
    setRowStyle(sheet, headerRow, totalCols, styleHeader());
    rowIdx++;

    // ── Tulis data per hierarki ─────────────────────────────────
    final Map<String, double> totalKategori = {};

    for (final kat in listAllKategori) {
      final katRow = rowIdx;
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: katRow))
          .value = excel.TextCellValue('');
      sheet
          .cell(excel.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: katRow))
          .value = excel.TextCellValue(kat.nama.toUpperCase());
      for (int c = 2; c < totalCols; c++) {
        sheet
            .cell(excel.CellIndex.indexByColumnRow(
                columnIndex: c, rowIndex: katRow))
            .value = excel.TextCellValue('');
      }
      setRowStyle(sheet, katRow, totalCols, styleGroup());
      rowIdx++;

      final subList = listAllSubKategori
          .where((s) => s.kategoriId == kat.id)
          .toList();

      if (subList.isNotEmpty) {
        for (final sub in subList) {
          final subRow = rowIdx;
          sheet
              .cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: subRow))
              .value = excel.TextCellValue('');
          sheet
              .cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: subRow))
              .value = excel.TextCellValue(sub.nama.toUpperCase());
          for (int c = 2; c < totalCols; c++) {
            sheet
                .cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: c, rowIndex: subRow))
                .value = excel.TextCellValue('');
          }
          setRowStyle(sheet, subRow, totalCols, styleGroup());
          rowIdx++;

          final tipeList = listAllTipeSampah
              .where((t) => t.subKategoriId == sub.id)
              .toList();

          if (tipeList.isNotEmpty) {
            for (final tipe in tipeList) {
              final tipeRow = rowIdx;
              sheet
                  .cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: 0, rowIndex: tipeRow))
                  .value = excel.TextCellValue('');
              sheet
                  .cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: 1, rowIndex: tipeRow))
                  .value = excel.TextCellValue(tipe.nama);
              for (int c = 2; c < totalCols; c++) {
                sheet
                    .cell(excel.CellIndex.indexByColumnRow(
                        columnIndex: c, rowIndex: tipeRow))
                    .value = excel.TextCellValue('');
              }
              setRowStyle(sheet, tipeRow, totalCols, styleGroup());
              rowIdx++;

              final jenisList = listAllJenisSampah
                  .where((j) =>
                      j.subKategoriId == sub.id && j.tipeId == tipe.id)
                  .toList();

              int noUrut = 1;
              for (final jenis in jenisList) {
                final baris = rowIdx;
                sheet
                    .cell(excel.CellIndex.indexByColumnRow(
                        columnIndex: 0, rowIndex: baris))
                    .value = excel.TextCellValue('$noUrut');
                sheet
                    .cell(excel.CellIndex.indexByColumnRow(
                        columnIndex: 1, rowIndex: baris))
                    .value = excel.TextCellValue(jenis.nama);

                double rowTotal = 0;
                for (int i = 0; i < nasabahKolom.length; i++) {
                  final jumlah =
                      pivot[jenis.id]?[nasabahKolom[i]] ?? 0.0;
                  rowTotal += jumlah;
                  final cell = sheet.cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: i + 2, rowIndex: baris));
                  cell.value = jumlah > 0
                      ? excel.TextCellValue(FormatHelper.number(jumlah))
                      : excel.TextCellValue('');
                  cell.cellStyle = styleNumber();
                }
                final totalCell = sheet.cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: nasabahKolom.length + 2, rowIndex: baris));
                totalCell.value = rowTotal > 0
                    ? excel.TextCellValue(FormatHelper.number(rowTotal))
                    : excel.TextCellValue('');
                totalCell.cellStyle = styleNumber();

                sheet
                    .cell(excel.CellIndex.indexByColumnRow(
                        columnIndex: 0, rowIndex: baris))
                    .cellStyle = styleNumber();
                sheet
                    .cell(excel.CellIndex.indexByColumnRow(
                        columnIndex: 1, rowIndex: baris))
                    .cellStyle = styleData();

                totalKategori[kat.id] =
                    (totalKategori[kat.id] ?? 0) + rowTotal;
                noUrut++;
                rowIdx++;
              }
            }
          } else {
            final jenisList = listAllJenisSampah
                .where((j) => j.subKategoriId == sub.id)
                .toList();

            int noUrut = 1;
            for (final jenis in jenisList) {
              final baris = rowIdx;
              sheet
                  .cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: 0, rowIndex: baris))
                  .value = excel.TextCellValue('$noUrut');
              sheet
                  .cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: 1, rowIndex: baris))
                  .value = excel.TextCellValue(jenis.nama);

              double rowTotal = 0;
              for (int i = 0; i < nasabahKolom.length; i++) {
                final jumlah =
                    pivot[jenis.id]?[nasabahKolom[i]] ?? 0.0;
                rowTotal += jumlah;
                final cell = sheet.cell(excel.CellIndex.indexByColumnRow(
                    columnIndex: i + 2, rowIndex: baris));
                cell.value = jumlah > 0
                    ? excel.TextCellValue(FormatHelper.number(jumlah))
                    : excel.TextCellValue('');
                cell.cellStyle = styleNumber();
              }
              final totalCell = sheet.cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: nasabahKolom.length + 2, rowIndex: baris));
              totalCell.value = rowTotal > 0
                  ? excel.TextCellValue(FormatHelper.number(rowTotal))
                  : excel.TextCellValue('');
              totalCell.cellStyle = styleNumber();

              sheet
                  .cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: 0, rowIndex: baris))
                  .cellStyle = styleNumber();
              sheet
                  .cell(excel.CellIndex.indexByColumnRow(
                      columnIndex: 1, rowIndex: baris))
                  .cellStyle = styleData();

              totalKategori[kat.id] =
                  (totalKategori[kat.id] ?? 0) + rowTotal;
              noUrut++;
              rowIdx++;
            }
          }
        }
      } else {
        final jenisList = listAllJenisSampah
            .where((j) => j.kategoriId == kat.id)
            .toList();

        int noUrut = 1;
        for (final jenis in jenisList) {
          final baris = rowIdx;
          sheet
              .cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: baris))
              .value = excel.TextCellValue('$noUrut');
          sheet
              .cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: baris))
              .value = excel.TextCellValue(jenis.nama);

          double rowTotal = 0;
          for (int i = 0; i < nasabahKolom.length; i++) {
            final jumlah = pivot[jenis.id]?[nasabahKolom[i]] ?? 0.0;
            rowTotal += jumlah;
            final cell = sheet.cell(excel.CellIndex.indexByColumnRow(
                columnIndex: i + 2, rowIndex: baris));
            cell.value = jumlah > 0
                ? excel.TextCellValue(FormatHelper.number(jumlah))
                : excel.TextCellValue('');
            cell.cellStyle = styleNumber();
          }
          final totalCell = sheet.cell(excel.CellIndex.indexByColumnRow(
              columnIndex: nasabahKolom.length + 2, rowIndex: baris));
          totalCell.value = rowTotal > 0
              ? excel.TextCellValue(FormatHelper.number(rowTotal))
              : excel.TextCellValue('');
          totalCell.cellStyle = styleNumber();

          sheet
              .cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: 0, rowIndex: baris))
              .cellStyle = styleNumber();
          sheet
              .cell(excel.CellIndex.indexByColumnRow(
                  columnIndex: 1, rowIndex: baris))
              .cellStyle = styleData();

          totalKategori[kat.id] =
              (totalKategori[kat.id] ?? 0) + rowTotal;
          noUrut++;
          rowIdx++;
        }
      }
    }

    rowIdx++;

    final judulTotalRow = rowIdx;
    sheet
        .cell(excel.CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: judulTotalRow))
        .value = excel.TextCellValue('');
    sheet
        .cell(excel.CellIndex.indexByColumnRow(
            columnIndex: 1, rowIndex: judulTotalRow))
        .value = excel.TextCellValue('JUMLAH');
    setRowStyle(sheet, judulTotalRow, totalCols, styleGroup());
    rowIdx++;

    for (final kat in listAllKategori) {
      final totalRow = rowIdx;
      sheet
          .cell(excel.CellIndex.indexByColumnRow(
              columnIndex: 0, rowIndex: totalRow))
          .value = excel.TextCellValue('');
      sheet
          .cell(excel.CellIndex.indexByColumnRow(
              columnIndex: 1, rowIndex: totalRow))
          .value = excel.TextCellValue(kat.nama);
      for (int c = 2; c < totalCols - 1; c++) {
        sheet
            .cell(excel.CellIndex.indexByColumnRow(
                columnIndex: c, rowIndex: totalRow))
            .value = excel.TextCellValue('');
      }
      final val = totalKategori[kat.id] ?? 0;
      sheet
          .cell(excel.CellIndex.indexByColumnRow(
              columnIndex: totalCols - 1, rowIndex: totalRow))
          .value = val > 0
          ? excel.TextCellValue(FormatHelper.number(val))
          : excel.TextCellValue('');
      setRowStyle(sheet, totalRow, totalCols, styleData());
      rowIdx++;
    }

    final grandTotal =
        totalKategori.values.fold(0.0, (sum, v) => sum + v);
    final grandRow = rowIdx;
    sheet
        .cell(excel.CellIndex.indexByColumnRow(
            columnIndex: 0, rowIndex: grandRow))
        .value = excel.TextCellValue('');
    sheet
        .cell(excel.CellIndex.indexByColumnRow(
            columnIndex: 1, rowIndex: grandRow))
        .value = excel.TextCellValue('GRAND TOTAL');
    for (int c = 2; c < totalCols - 1; c++) {
      sheet
          .cell(excel.CellIndex.indexByColumnRow(
              columnIndex: c, rowIndex: grandRow))
          .value = excel.TextCellValue('');
    }
    sheet
        .cell(excel.CellIndex.indexByColumnRow(
            columnIndex: totalCols - 1, rowIndex: grandRow))
        .value = grandTotal > 0
        ? excel.TextCellValue(FormatHelper.number(grandTotal))
        : excel.TextCellValue('');
    setRowStyle(sheet, grandRow, totalCols, styleGroup());
  }

  String _namaBulan(int bulan) {
    const bulanList = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return bulanList[bulan];
  }  

  Future<void> exportCsv() async {
    if (!isValid) {
      Get.snackbar('Validasi', 'Tentukan periode laporan terlebih dahulu.');
      return;
    }
    isGenerating.value = true;
    try {
      if (listAllKategori.isEmpty) await _fetchMasterData();

      List<PengelolaanSampahModel> data = previewData;
      if (data.isEmpty) data = await _fetchDataLaporan();

      if (data.isEmpty) {
        Get.snackbar('Info', 'Tidak ada data transaksi untuk diexport.');
        return;
      }

      final mulai = selectedTanggalMulai.value!;
      final akhir = selectedTanggalAkhir.value!;
      final selisihHari = akhir.difference(mulai).inDays;
      final isMultiBulan = selisihHari > 31;

      final Set<String> activeNasabahs = data
          .map((e) => e.namaNasabah)
          .where((name) => name != null && name.trim().isNotEmpty)
          .map((name) => name!.trim())
          .toSet();

      final List<String> nasabahKolom = selectedNasabah.value != null && selectedNasabah.value!.isNotEmpty
          ? [selectedNasabah.value!]
          : activeNasabahs.toList();
      nasabahKolom.sort((a, b) => a.compareTo(b));

      final Map<String, Map<String, Map<String, double>>> pivot = {};
      for (final item in data) {
        final jId = item.jenisSampah?.id;
        if (jId == null) continue;
        final tgl = item.tanggalPengelolaan;
        final nasName = item.namaNasabah ?? '';
        final bulanKey = isMultiBulan
            ? '${_namaBulan(tgl.month).toUpperCase()} ${tgl.year}'
            : '';

        final pivotBulan = pivot.putIfAbsent(bulanKey, () => {});
        final pivotJenis = pivotBulan.putIfAbsent(jId, () => {});
        pivotJenis[nasName] = (pivotJenis[nasName] ?? 0) + item.jumlah;
      }

      final List<String> bulanKeys = isMultiBulan
          ? pivot.keys.toList()
          : [''];

      final csvData = <List<dynamic>>[];

      final header = <dynamic>[];
      if (isMultiBulan) {
        header.add('BULAN');
      }
      header.add('NO');
      header.add('JENIS SAMPAH');
      for (final n in nasabahKolom) {
        header.add(n);
      }
      header.add('TOTAL');
      csvData.add(header);

      final judulRow = <dynamic>[];
      if (isMultiBulan) {
        judulRow.add('');
      }
      judulRow.addAll(['LAPORAN SAMPAH BANK SAMPAH ${SessionService.to.activeBankSampahNama.toUpperCase()}', ...List.filled(nasabahKolom.length + 1, '')]);
      
      final periodeRow = <dynamic>[];
      if (isMultiBulan) {
        periodeRow.add('');
      }
      periodeRow.addAll([
        'BULAN : ${FormatHelper.date(mulai)} - ${FormatHelper.date(akhir)}',
        ...List.filled(nasabahKolom.length + 1, '')
      ]);

      csvData.insert(0, periodeRow);
      csvData.insert(0, judulRow);
      csvData.insert(1, []);

      for (final bulanKey in bulanKeys) {
        final pivotBulan = pivot[bulanKey] ?? {};
        final Map<String, double> totalKategori = {};

        if (isMultiBulan) {
          csvData.add([bulanKey, ...List.filled(nasabahKolom.length + 2, '')]);
        }

        for (final kat in listAllKategori) {
          final katRow = <dynamic>[];
          if (isMultiBulan) {
            katRow.add('');
          }
          katRow.addAll(['', kat.nama.toUpperCase(), ...List.filled(nasabahKolom.length + 1, '')]);
          csvData.add(katRow);

          final subList = listAllSubKategori.where((s) => s.kategoriId == kat.id).toList();

          if (subList.isNotEmpty) {
            for (final sub in subList) {
              final subRow = <dynamic>[];
              if (isMultiBulan) {
                subRow.add('');
              }
              subRow.addAll(['', '  ${sub.nama.toUpperCase()}', ...List.filled(nasabahKolom.length + 1, '')]);
              csvData.add(subRow);

              final tipeList = listAllTipeSampah.where((t) => t.subKategoriId == sub.id).toList();

              if (tipeList.isNotEmpty) {
                for (final tipe in tipeList) {
                  final tipeRow = <dynamic>[];
                  if (isMultiBulan) {
                    tipeRow.add('');
                  }
                  tipeRow.addAll(['', '    ${tipe.nama}', ...List.filled(nasabahKolom.length + 1, '')]);
                  csvData.add(tipeRow);

                  final jenisList = listAllJenisSampah
                      .where((j) => j.subKategoriId == sub.id && j.tipeId == tipe.id)
                      .toList();

                  int no = 1;
                  for (final jenis in jenisList) {
                    double rowTotal = 0;
                    final row = <dynamic>[];
                    if (isMultiBulan) {
                      row.add('');
                    }
                    row.add('$no');
                    row.add('      ${jenis.nama}');
                    for (final n in nasabahKolom) {
                      final jumlah = pivotBulan[jenis.id]?[n] ?? 0.0;
                      rowTotal += jumlah;
                      row.add(jumlah > 0 ? FormatHelper.number(jumlah) : '');
                    }
                    row.add(rowTotal > 0 ? FormatHelper.number(rowTotal) : '');
                    csvData.add(row);
                    totalKategori[kat.id] = (totalKategori[kat.id] ?? 0) + rowTotal;
                    no++;
                  }
                }
              } else {
                final jenisList = listAllJenisSampah
                    .where((j) => j.subKategoriId == sub.id)
                    .toList();

                int no = 1;
                for (final jenis in jenisList) {
                  double rowTotal = 0;
                  final row = <dynamic>[];
                  if (isMultiBulan) {
                    row.add('');
                  }
                  row.add('$no');
                  row.add('    ${jenis.nama}');
                  for (final n in nasabahKolom) {
                    final jumlah = pivotBulan[jenis.id]?[n] ?? 0.0;
                    rowTotal += jumlah;
                    row.add(jumlah > 0 ? FormatHelper.number(jumlah) : '');
                  }
                  row.add(rowTotal > 0 ? FormatHelper.number(rowTotal) : '');
                  csvData.add(row);
                  totalKategori[kat.id] = (totalKategori[kat.id] ?? 0) + rowTotal;
                  no++;
                }
              }
            }
          } else {
            final jenisList = listAllJenisSampah
                .where((j) => j.kategoriId == kat.id)
                .toList();

            int no = 1;
            for (final jenis in jenisList) {
              double rowTotal = 0;
              final row = <dynamic>[];
              if (isMultiBulan) {
                row.add('');
              }
              row.add('$no');
              row.add('  ${jenis.nama}');
              for (final n in nasabahKolom) {
                final jumlah = pivotBulan[jenis.id]?[n] ?? 0.0;
                rowTotal += jumlah;
                row.add(jumlah > 0 ? FormatHelper.number(jumlah) : '');
              }
              row.add(rowTotal > 0 ? FormatHelper.number(rowTotal) : '');
              csvData.add(row);
              totalKategori[kat.id] = (totalKategori[kat.id] ?? 0) + rowTotal;
              no++;
            }
          }
        }

        csvData.add([]);

        final jumlahLabelRow = <dynamic>[];
        if (isMultiBulan) {
          jumlahLabelRow.add('');
        }
        jumlahLabelRow.addAll(['', 'JUMLAH', ...List.filled(nasabahKolom.length + 1, '')]);
        csvData.add(jumlahLabelRow);

        for (final kat in listAllKategori) {
          final val = totalKategori[kat.id] ?? 0;
          final totRow = <dynamic>[];
          if (isMultiBulan) {
            totRow.add('');
          }
          totRow.add('');
          totRow.add(kat.nama);
          totRow.addAll(List.filled(nasabahKolom.length, ''));
          totRow.add(val > 0 ? FormatHelper.number(val) : '');
          csvData.add(totRow);
        }

        final grandTotal = totalKategori.values.fold(0.0, (s, v) => s + v);
        final grandRow = <dynamic>[];
        if (isMultiBulan) {
          grandRow.add('');
        }
        grandRow.add('');
        grandRow.add('GRAND TOTAL');
        grandRow.addAll(List.filled(nasabahKolom.length, ''));
        grandRow.add(grandTotal > 0 ? FormatHelper.number(grandTotal) : '');
        csvData.add(grandRow);

        if (isMultiBulan) {
          csvData.add([]);
        }
      }

      final csvString = const ListToCsvConverter().convert(csvData);
      final csvWithBom = '\uFEFF$csvString';

      final startStr = FormatHelper.dateToInput(mulai).replaceAll('-', '');
      final endStr = FormatHelper.dateToInput(akhir).replaceAll('-', '');
      final bsuName = SessionService.to.activeBankSampahNama
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-z0-9_]'), '');
      final fileName = 'laporan_sampah_${bsuName}_$startStr-$endStr.csv';
      final shareText =
          'Laporan Bank Sampah ${SessionService.to.activeBankSampahNama} ${FormatHelper.date(mulai)} - ${FormatHelper.date(akhir)}';

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsString(csvWithBom, encoding: utf8);

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: shareText,
      );
      Get.snackbar('Sukses', 'Laporan CSV berhasil diexport dan siap dibagikan.');
    } catch (e) {
      Get.snackbar('Gagal', 'Export CSV gagal: $e');
    } finally {
      isGenerating.value = false;
    }
  }
}
