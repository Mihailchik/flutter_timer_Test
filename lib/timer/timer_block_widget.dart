import 'package:flutter/material.dart';
import 'timer_model.dart';
import 'time_input_widget.dart';

class TimerBlockWidget extends StatefulWidget {
  final TimerBlock block;
  final VoidCallback onDelete;
  final Function(TimerBlock) onUpdate;
  final bool showDeleteButton; // Whether to show delete button

  const TimerBlockWidget({
    super.key,
    required this.block,
    required this.onDelete,
    required this.onUpdate,
    this.showDeleteButton = true,
  });

  @override
  State<TimerBlockWidget> createState() => _TimerBlockWidgetState();
}

class _TimerBlockWidgetState extends State<TimerBlockWidget> {
  late TextEditingController _nameController;
  late TextEditingController _repeatsController;
  late List<TextEditingController>
  _itemControllers; // Controllers for timer item names

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.block.name);
    _repeatsController = TextEditingController(
      text: widget.block.repeats.toString(),
    );

    // Initialize controllers for timer item names
    _itemControllers = [];
    for (int i = 0; i < widget.block.items.length; i++) {
      _itemControllers.add(
        TextEditingController(text: widget.block.items[i].name),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _repeatsController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateBlock() {
    final name = _nameController.text.isEmpty ? 'Block' : _nameController.text;

    int repeats = 1;
    try {
      repeats = int.tryParse(_repeatsController.text) ?? 1;
    } catch (e) {
      repeats = 1;
    }

    if (repeats < 1) repeats = 1;

    // Create updated items list
    final List<TimerItem> updatedItems = [];
    for (int i = 0; i < widget.block.items.length; i++) {
      final itemName = _itemControllers[i].text.isEmpty
          ? _generateDefaultName(i)
          : _itemControllers[i].text;

      // Use the existing duration from the item
      final duration = widget.block.items[i].duration;

      updatedItems.add(
        TimerItem(
          name: itemName,
          duration: duration,
          isPause: i % 2 == 1, // Чередуем упражнения и паузы
        ),
      );
    }

    widget.onUpdate(
      widget.block.copyWith(name: name, items: updatedItems, repeats: repeats),
    );
  }

  String _generateDefaultName(int index) {
    if (index % 2 == 0) {
      // Exercise
      final exerciseNumber = (index ~/ 2) + 1;
      return 'Exercise $exerciseNumber';
    } else {
      // Rest
      final restNumber = (index + 1) ~/ 2;
      return 'Rest $restNumber';
    }
  }

  void _addItem() {
    setState(() {
      // Add new controller for the new item name
      final newIndex = widget.block.items.length;
      _itemControllers.add(
        TextEditingController(text: _generateDefaultName(newIndex)),
      );

      // Create updated items list with new item
      final List<TimerItem> updatedItems = List.from(widget.block.items);
      updatedItems.add(
        TimerItem(
          name: _generateDefaultName(newIndex),
          duration: 30, // 30 seconds default
          isPause: newIndex % 2 == 1, // Чередуем упражнения и паузы
        ),
      );

      widget.onUpdate(widget.block.copyWith(items: updatedItems));
    });
  }

  void _deleteItem(int index) {
    if (widget.block.items.length <= 2) {
      // Keep at least 2 items (1 exercise + 1 pause)
      return;
    }

    setState(() {
      // Remove controller for the deleted item
      if (index < _itemControllers.length) {
        _itemControllers.removeAt(index);
      }

      // Create updated items list without deleted item
      final List<TimerItem> updatedItems = List.from(widget.block.items);
      updatedItems.removeAt(index);

      widget.onUpdate(widget.block.copyWith(items: updatedItems));
    });
  }

  // Метод для увеличения повторов
  void _increaseRepeats() {
    try {
      final currentRepeats = int.tryParse(_repeatsController.text) ?? 1;
      _repeatsController.text = (currentRepeats + 1).toString();
      _updateBlock();
    } catch (e) {
      // Игнорируем ошибки
    }
  }

  // Метод для уменьшения повторов
  void _decreaseRepeats() {
    try {
      final currentRepeats = int.tryParse(_repeatsController.text) ?? 1;
      if (currentRepeats > 1) {
        _repeatsController.text = (currentRepeats - 1).toString();
        _updateBlock();
      }
    } catch (e) {
      // Игнорируем ошибки
    }
  }

  // Метод для обновления времени таймера
  void _updateItemTime(int index, int newDuration) {
    final List<TimerItem> updatedItems = List.from(widget.block.items);
    if (index < updatedItems.length) {
      updatedItems[index] = updatedItems[index].copyWith(duration: newDuration);

      widget.onUpdate(widget.block.copyWith(items: updatedItems));
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.of(context).size.width < 360;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Основная строка шапки: имя блока и повторы. Паддинг справа под кнопку удаления.
                Padding(
                  padding: const EdgeInsets.only(right: 48.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Block name',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                          ),
                          style: TextStyle(fontSize: compact ? 12 : 14),
                          onChanged: (value) => _updateBlock(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Поле повторов с кнопками
                      SizedBox(
                        width: compact ? 110 : 140,
                        child: Row(
                          children: [
                            SizedBox(
                              width: compact ? 56 : 70,
                              child: TextField(
                                controller: _repeatsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Repeats',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 10,
                                  ),
                                ),
                                style: TextStyle(fontSize: compact ? 12 : 14),
                                onChanged: (value) => _updateBlock(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: compact ? 24 : 32,
                                  height: compact ? 24 : 32,
                                  child: ElevatedButton(
                                    onPressed: _increaseRepeats,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      shape: const CircleBorder(),
                                      minimumSize: Size(
                                        compact ? 24 : 32,
                                        compact ? 24 : 32,
                                      ),
                                      visualDensity: compact
                                          ? const VisualDensity(
                                              horizontal: -2, vertical: -2)
                                          : VisualDensity.standard,
                                    ),
                                    child: Icon(
                                      Icons.arrow_drop_up,
                                      size: compact ? 20 : 24,
                                    ),
                                  ),
                                ),
                                SizedBox(height: compact ? 2 : 4),
                                SizedBox(
                                  width: compact ? 24 : 32,
                                  height: compact ? 24 : 32,
                                  child: ElevatedButton(
                                    onPressed: _decreaseRepeats,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.all(0),
                                      shape: const CircleBorder(),
                                      minimumSize: Size(
                                        compact ? 24 : 32,
                                        compact ? 24 : 32,
                                      ),
                                      visualDensity: compact
                                          ? const VisualDensity(
                                              horizontal: -2, vertical: -2)
                                          : VisualDensity.standard,
                                    ),
                                    child: Icon(
                                      Icons.arrow_drop_down,
                                      size: compact ? 20 : 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Кнопка удаления поверх справа, не влияет на раскладку
                if (widget.showDeleteButton)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 20,
                      ),
                      onPressed: widget.onDelete,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Timers in block:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List.generate(widget.block.items.length, (index) {
              final item = widget.block.items[index];
              final nameController = index < _itemControllers.length
                  ? _itemControllers[index]
                  : TextEditingController();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    // Показываем цвет таймера
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: index % 2 == 0 ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Название таймера — гибкое поле, занимает доступное место
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                        onChanged: (value) => _updateBlock(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Поле ввода времени с кнопками
                    Builder(
                      builder: (context) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isCompact = screenWidth < 360;
                        double timeWidth = (screenWidth - 32) * 0.28;
                        timeWidth = isCompact
                            ? timeWidth.clamp(100.0, 160.0)
                            : timeWidth.clamp(140.0, 200.0);
                        return SizedBox(
                          width: timeWidth,
                          child: TimeInputWidget(
                            initialSeconds: item.duration,
                            onTimeChanged: (newDuration) =>
                                _updateItemTime(index, newDuration),
                            label: 'MM:SS',
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    // Резервируем место под кнопку удаления для стабильной ширины
                    (widget.block.items.length > 2)
                        ? IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => _deleteItem(index),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 32, // Увеличили минимальную ширину
                              minHeight: 32, // Увеличили минимальную высоту
                            ),
                          )
                        : const SizedBox(width: 32, height: 32),
                  ],
                ),
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                  ), // Увеличили размер иконки
                  label: Text(
                    'Add timer',
                    style: TextStyle(fontSize: compact ? 12 : 14),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 12,
                      vertical: compact ? 4 : 8,
                    ),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity:
                        compact ? const VisualDensity(horizontal: -2, vertical: -2) : VisualDensity.standard,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
