import 'package:intl/intl.dart';
import 'package:malta_wash/Src/Features/booking/domain/booking_repository.dart';
import 'package:malta_wash/Src/Features/vehicles/domain/vehicles_repository.dart';
import 'package:signals/signals.dart';

class BookingController {
  BookingController(this._booking, this._vehicles);
  final BookingRepository _booking;
  final VehiclesRepository _vehicles;

  final isLoading = signal(false);
  final errorMessage = signal<String?>(null);
  final step = signal(0);
  final vehicles = signal<List<Map<String, dynamic>>>(const []);
  final services = signal<List<Map<String, dynamic>>>(const []);
  final slots = signal<List<Map<String, dynamic>>>(const []);

  final vehicleId = signal<String?>(null);
  final serviceId = signal<String?>(null);
  final date = signal<DateTime?>(null);
  final startAt = signal<String?>(null);

  String? _legacyLocationId;
  Map<String, dynamic> _settings = const {};

  Future<void> bootstrap() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _booking.services(),
        _vehicles.list(),
        _loadDefaultLocation(),
      ]);

      services.value = (results[0] as List<Map<String, dynamic>>)
          .where(_hasUsableId)
          .where((item) => item['active'] != false)
          .toList();
      vehicles.value = (results[1] as List)
          .map((v) => <String, dynamic>{
                'id': v.id,
                'plate': v.plate,
                'model': v.model,
                'color': v.color,
                'category': v.category,
              })
          .where(_hasUsableId)
          .toList();

      if (vehicles.value.length == 1) vehicleId.value = _id(vehicles.value.first);
      if (services.value.length == 1) serviceId.value = _id(services.value.first);
    } catch (e) {
      errorMessage.value = _friendlyError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDefaultLocation() async {
    try {
      _settings = await _booking.settings();
      for (final key in const [
        'defaultLocationId',
        'locationId',
        'locationObjectId',
      ]) {
        final value = _settings[key]?.toString().trim() ?? '';
        if (value.isNotEmpty) {
          _legacyLocationId = value;
          return;
        }
      }

      final location = _settings['location'];
      if (location is Map) {
        final map = location.map((k, v) => MapEntry(k.toString(), v));
        final value = _id(map);
        if (value.isNotEmpty) {
          _legacyLocationId = value;
          return;
        }
      }
    } catch (_) {}

    try {
      final items = (await _booking.locations()).where(_hasUsableId).toList();
      final active = items.where((item) => item['active'] != false).toList();
      final source = active.isNotEmpty ? active : items;
      if (source.isNotEmpty) _legacyLocationId = _id(source.first);
    } catch (_) {
      _legacyLocationId = null;
    }
  }

  Future<void> loadSlots() async {
    if (vehicleId.value == null || serviceId.value == null || date.value == null) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    startAt.value = null;

    try {
      _legacyLocationId ??= _locationFromSelectedService();
      if (_legacyLocationId == null || _legacyLocationId!.isEmpty) {
        await _loadDefaultLocation();
      }

      final dateText = DateFormat('yyyy-MM-dd').format(date.value!);
      List<Map<String, dynamic>> rawSlots = const [];

      try {
        rawSlots = await _booking.availability(
          locationId: _legacyLocationId,
          serviceId: serviceId.value!,
          vehicleId: vehicleId.value!,
          date: dateText,
        );
      } catch (_) {
        rawSlots = const [];
      }

      var normalized = rawSlots
          .map(_normalizeSlot)
          .where((slot) => slot['available'] != false)
          .where((slot) =>
              (slot['startAt'] ?? '').toString().trim().isNotEmpty)
          .toList();

      if (normalized.isEmpty) {
        normalized = await _buildSlotsFromCompanySchedule(dateText);
      }

      slots.value = normalized;
      if (normalized.isEmpty) {
        errorMessage.value =
            'Não há horários livres para esta data. Escolha outro dia.';
      }
    } catch (e) {
      errorMessage.value = _friendlyError(e);
      slots.value = const [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _buildSlotsFromCompanySchedule(
      String dateText) async {
    if (_settings.isEmpty) {
      try {
        _settings = await _booking.settings();
      } catch (_) {
        return const [];
      }
    }

    final selectedDate = date.value!;
    final workingDays = _settings['workingDays'];
    if (workingDays is List && workingDays.isNotEmpty) {
      final allowed = workingDays
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toSet();
      if (!allowed.contains(selectedDate.weekday)) return const [];
    }

    final opening = _settingText(
      const ['openingTime', 'opensAt'],
      fallback: '08:00',
    );
    final closing = _settingText(
      const ['closingTime', 'closesAt'],
      fallback: '18:00',
    );
    final slotMinutes = int.tryParse(
          _settingText(
            const ['slotMinutes', 'slotIntervalMinutes'],
            fallback: '30',
          ),
        ) ??
        30;

    final service = _selectedService();
    final durationMinutes = int.tryParse(
          (service['durationMinutes'] ?? service['duration'] ?? slotMinutes)
              .toString(),
        ) ??
        slotMinutes;

    final openTime = _combineDateAndTime(opening);
    final closeTime = _combineDateAndTime(closing);
    final open = DateTime.tryParse(openTime);
    final close = DateTime.tryParse(closeTime);
    if (open == null || close == null || !close.isAfter(open)) return const [];

    List<Map<String, dynamic>> appointments = const [];
    try {
      appointments = await _booking.appointments(
        locationId: _legacyLocationId,
        date: dateText,
      );
    } catch (_) {}

    final busyRanges = appointments
        .where((item) => !_isCancelled(item))
        .map(_appointmentRange)
        .whereType<_TimeRange>()
        .toList();

    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];
    var cursor = open;

    while (!cursor.add(Duration(minutes: durationMinutes)).isAfter(close)) {
      final end = cursor.add(Duration(minutes: durationMinutes));
      final inPast = cursor.isBefore(now);
      final conflicts = busyRanges.any(
        (busy) => cursor.isBefore(busy.end) && end.isAfter(busy.start),
      );

      if (!inPast && !conflicts) {
        result.add({
          'startAt': cursor.toIso8601String(),
          'start': DateFormat('HH:mm').format(cursor),
          'available': true,
        });
      }

      cursor = cursor.add(Duration(minutes: slotMinutes <= 0 ? 30 : slotMinutes));
    }

    return result;
  }

  _TimeRange? _appointmentRange(Map<String, dynamic> item) {
    final rawStart = _firstNonEmpty(item, const [
      'startAt',
      'start',
      'startsAt',
      'dateTime',
      'scheduledAt',
    ]);
    if (rawStart.isEmpty) return null;

    final start = DateTime.tryParse(rawStart) ??
        (_looksLikeTime(rawStart) ? DateTime.tryParse(_combineDateAndTime(rawStart)) : null);
    if (start == null) return null;

    final rawEnd = _firstNonEmpty(item, const ['endAt', 'end', 'endsAt']);
    final explicitEnd = DateTime.tryParse(rawEnd);
    if (explicitEnd != null) return _TimeRange(start, explicitEnd);

    final itemDuration = int.tryParse(
      (item['durationMinutes'] ?? item['duration'] ?? 60).toString(),
    );
    return _TimeRange(start, start.add(Duration(minutes: itemDuration ?? 60)));
  }

  bool _isCancelled(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    return status.contains('cancel') || status == 'no_show' || status == 'noshow';
  }

  Future<Map<String, dynamic>?> confirm() async {
    if (vehicleId.value == null ||
        serviceId.value == null ||
        startAt.value == null) {
      errorMessage.value = 'Preencha todas as etapas obrigatórias.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = null;
    try {
      _legacyLocationId ??= _locationFromSelectedService();
      if (_legacyLocationId == null || _legacyLocationId!.isEmpty) {
        await _loadDefaultLocation();
      }

      return await _booking.createAppointment({
        if (_legacyLocationId != null && _legacyLocationId!.isNotEmpty)
          'locationId': _legacyLocationId,
        'vehicleId': vehicleId.value,
        'serviceId': serviceId.value,
        'startAt': startAt.value,
      });
    } catch (e) {
      errorMessage.value = _friendlyError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _normalizeSlot(Map<String, dynamic> raw) {
    final normalized = Map<String, dynamic>.from(raw);
    final direct = _firstNonEmpty(raw, const [
      'startAt',
      'start',
      'dateTime',
      'datetime',
      'value',
      'startsAt',
      'slotStart',
    ]);
    final time = _firstNonEmpty(raw, const [
      'time',
      'hour',
      'label',
      'startTime',
      'startsAtTime',
    ]);

    String resolved = direct.trim();
    String display = time.trim();

    if (_looksLikeTime(resolved) && date.value != null) {
      display = display.isNotEmpty ? display : resolved;
      resolved = _combineDateAndTime(resolved);
    } else if (resolved.isEmpty && _looksLikeTime(display) && date.value != null) {
      resolved = _combineDateAndTime(display);
    }

    normalized['startAt'] = resolved;
    if ((normalized['start'] ?? '').toString().trim().isEmpty) {
      normalized['start'] = display.isNotEmpty ? display : _timeFromDateTime(resolved);
    }
    normalized['available'] = normalized['available'] != false;
    return normalized;
  }

  bool _looksLikeTime(String value) =>
      RegExp(r'^\d{1,2}:\d{2}(?::\d{2})?$').hasMatch(value.trim());

  String _combineDateAndTime(String time) {
    final datePart = DateFormat('yyyy-MM-dd').format(date.value!);
    final pieces = time.trim().split(':');
    final hour = pieces.first.padLeft(2, '0');
    final minute = pieces.length > 1 ? pieces[1].padLeft(2, '0') : '00';
    final second = pieces.length > 2 ? pieces[2].padLeft(2, '0') : '00';
    return '${datePart}T$hour:$minute:$second';
  }

  String _timeFromDateTime(String value) {
    if (value.isEmpty) return '';
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateFormat('HH:mm').format(parsed);
    final match = RegExp(r'T(\d{2}:\d{2})').firstMatch(value);
    return match?.group(1) ?? value;
  }

  Map<String, dynamic> _selectedService() {
    for (final item in services.value) {
      if (_id(item) == serviceId.value) return item;
    }
    return const {};
  }

  String? _locationFromSelectedService() {
    final selected = _selectedService();
    if (selected.isEmpty) return null;

    for (final key in const [
      'locationId',
      'defaultLocationId',
      'locationObjectId',
    ]) {
      final value = selected[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    final location = selected['location'];
    if (location is Map) {
      final map = location.map((k, v) => MapEntry(k.toString(), v));
      final value = _id(map);
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  String _settingText(List<String> keys, {required String fallback}) {
    for (final key in keys) {
      final value = _settings[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return fallback;
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    final lower = text.toLowerCase();
    if (lower.contains('locationid') ||
        lower.contains('location id') ||
        (lower.contains('location') && lower.contains('obrigat'))) {
      return 'A agenda ainda não possui um local padrão ativo. Abra Configurações da empresa e salve os horários para ativar a agenda.';
    }
    return text;
  }

  String _firstNonEmpty(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  bool _hasUsableId(Map<String, dynamic> item) => _id(item).isNotEmpty;

  String _id(Map<String, dynamic> item) =>
      (item['id'] ?? item['objectId'] ?? '').toString().trim();
}

class _TimeRange {
  const _TimeRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}
