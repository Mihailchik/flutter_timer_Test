import 'package:flutter/material.dart';

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
    if (timeString.contains(':')) {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        try {
          final minutes = int.tryParse(parts[0]) ?? 0;
          final seconds = int.tryParse(parts[1]) ?? 0;
          return minutes * 60 + seconds;
        } catch (e) {
          // В случае ошибки возвращаем 0
        }
      }
    }
    // Если формат не MM:SS, попробуем интерпретировать как секунды
    try {
      final seconds = int.tryParse(timeString) ?? 0;
      return seconds;
    } catch (e) {
      // В случае ошибки возвращаем 0
    }
    return widget.initialSeconds;
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
    return SizedBox(
      width: 160, // Увеличили ширину для лучшего размещения
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12, // Увеличили вертикальный padding
                ),
              ),
              style: const TextStyle(fontSize: 14), // Увеличили размер шрифта
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Обработка изменений в реальном времени
                if (!_isFormatting) {
                  final parsedTime = _parseTime(value);
                  widget.onTimeChanged(parsedTime);
                }
              },
              onTapOutside: (event) {
                // Форматируем значение при клике вне поля
                _focusNode.unfocus();
                final parsedTime = _parseTime(_controller.text);
                _formatAndSetTime(parsedTime);
                _lastFormattedValue = _controller.text;
                widget.onTimeChanged(parsedTime);
              },
              onEditingComplete: () {
                // При завершении редактирования форматируем значение
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
          const SizedBox(width: 8), // Увеличили расстояние
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Увеличенные кнопки со стрелками
              SizedBox(
                width: 32, // Увеличили ширину
                height: 32, // Увеличили высоту
                child: ElevatedButton(
                  onPressed: () => _increaseTime(5),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    shape: const CircleBorder(),
                    minimumSize: const Size(32, 32),
                  ),
                  child: const Icon(
                    Icons.arrow_drop_up,
                    size: 24,
                  ), // Увеличили размер иконки
                ),
              ),
              const SizedBox(height: 4), // Увеличили расстояние между кнопками
              SizedBox(
                width: 32, // Увеличили ширину
                height: 32, // Увеличили высоту
                child: ElevatedButton(
                  onPressed: () => _decreaseTime(5),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    shape: const CircleBorder(),
                    minimumSize: const Size(32, 32),
                  ),
                  child: const Icon(
                    Icons.arrow_drop_down,
                    size: 24,
                  ), // Увеличили размер иконки
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
