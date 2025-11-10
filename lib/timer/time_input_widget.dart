import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TimeInputWidget extends StatefulWidget {
  final int initialSeconds;
  final Function(int) onTimeChanged;
  final String label;

  const TimeInputWidget({
    super.key,
    required this.initialSeconds,
    required this.onTimeChanged,
    this.label = 'MM:SS',
  });

  @override
  State<TimeInputWidget> createState() => _TimeInputWidgetState();
}

class _TimeInputWidgetState extends State<TimeInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _lastFormattedValue = '';
  bool _isFormatting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _formatAndSetTime(widget.initialSeconds);
    _lastFormattedValue = _controller.text;

    // Добавляем слушатель изменений
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant TimeInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSeconds != widget.initialSeconds &&
        !_focusNode.hasFocus) {
      _formatAndSetTime(widget.initialSeconds);
      _lastFormattedValue = _controller.text;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _formatAndSetTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    _controller.text = '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  int _parseTime(String timeString) {
    // Санитизация: оставляем только цифры и двоеточие
    final sanitized = timeString.replaceAll(RegExp(r'[^0-9:]'), '');

    if (sanitized.contains(':')) {
      final rawParts = sanitized.split(':');
      // Рассматриваем только первые два компонента
      final parts = rawParts.length >= 2
          ? [rawParts[0], rawParts[1]]
          : [rawParts[0], '0'];
      try {
        int minutes = int.tryParse(parts[0]) ?? 0;
        int seconds = int.tryParse(parts[1]) ?? 0;
        // Ограничиваем секунды диапазоном 0..59
        seconds = seconds.clamp(0, 59);
        return minutes * 60 + seconds;
      } catch (e) {
        // В случае ошибки возвращаем начальное значение
        return widget.initialSeconds;
      }
    }
    // Если формат не MM:SS, пробуем интерпретировать как секунды
    try {
      final seconds = int.tryParse(sanitized) ?? 0;
      return seconds;
    } catch (e) {
      // В случае ошибки возвращаем исходное значение
      return widget.initialSeconds;
    }
  }

  void _onTextChanged() {
    // Игнорируем изменения во время форматирования
    if (_isFormatting) return;

    final currentValue = _controller.text;

    // Если значение не изменилось, ничего не делаем
    if (currentValue == _lastFormattedValue) return;

    // Если фокус не на поле, ничего не делаем
    if (!_focusNode.hasFocus) return;

    // Парсим и отправляем значение
    final parsedTime = _parseTime(currentValue);
    widget.onTimeChanged(parsedTime);
  }

  void _increaseTime(int seconds) {
    // Убираем фокус с поля ввода перед изменением
    _focusNode.unfocus();

    final currentTime = _parseTime(_controller.text);
    final newTime = currentTime + seconds;
    _formatAndSetTime(newTime);
    _lastFormattedValue = _controller.text;
    widget.onTimeChanged(newTime);
  }

  void _decreaseTime(int seconds) {
    // Убираем фокус с поля ввода перед изменением
    _focusNode.unfocus();

    final currentTime = _parseTime(_controller.text);
    final newTime = currentTime - seconds;
    if (newTime >= 0) {
      _formatAndSetTime(newTime);
      _lastFormattedValue = _controller.text;
      widget.onTimeChanged(newTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 360;
    final inputPadding = EdgeInsets.symmetric(
      horizontal: compact ? 6 : 8,
      vertical: compact ? 6 : 12,
    );

    final textStyle = TextStyle(fontSize: compact ? 12 : 14);
    final spacerWidth = compact ? 6.0 : 8.0;
    final btnSize = compact ? 24.0 : 32.0;
    final iconSize = compact ? 20.0 : 24.0;
    final betweenBtns = compact ? 2.0 : 4.0;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: widget.label,
              border: const OutlineInputBorder(),
              contentPadding: inputPadding,
            ),
            style: textStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9:]+')),
            ],
            onChanged: (value) {
              if (!_isFormatting) {
                final parsedTime = _parseTime(value);
                widget.onTimeChanged(parsedTime);
              }
            },
            onTapOutside: (event) {
              _focusNode.unfocus();
              final parsedTime = _parseTime(_controller.text);
              _formatAndSetTime(parsedTime);
              _lastFormattedValue = _controller.text;
              widget.onTimeChanged(parsedTime);
            },
            onEditingComplete: () {
              final parsedTime = _parseTime(_controller.text);
              _isFormatting = true;
              _formatAndSetTime(parsedTime);
              _lastFormattedValue = _controller.text;
              _isFormatting = false;
              widget.onTimeChanged(parsedTime);
              _focusNode.unfocus();
            },
          ),
        ),
        SizedBox(width: spacerWidth),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: btnSize,
              height: btnSize,
              child: ElevatedButton(
                onPressed: () => _increaseTime(5),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  shape: const CircleBorder(),
                  minimumSize: Size(btnSize, btnSize),
                  visualDensity: compact
                      ? VisualDensity(horizontal: -2, vertical: -2)
                      : VisualDensity.standard,
                ),
                child: Icon(
                  Icons.arrow_drop_up,
                  size: iconSize,
                ),
              ),
            ),
            SizedBox(height: betweenBtns),
            SizedBox(
              width: btnSize,
              height: btnSize,
              child: ElevatedButton(
                onPressed: () => _decreaseTime(5),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  shape: const CircleBorder(),
                  minimumSize: Size(btnSize, btnSize),
                  visualDensity: compact
                      ? VisualDensity(horizontal: -2, vertical: -2)
                      : VisualDensity.standard,
                ),
                child: Icon(
                  Icons.arrow_drop_down,
                  size: iconSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
