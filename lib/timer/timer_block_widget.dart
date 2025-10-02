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
    final name = _nameController.text.isEmpty ? 'Блок' : _nameController.text;

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
      // Упражнение
      final exerciseNumber = (index ~/ 2) + 1;
      return 'Упражнение $exerciseNumber';
    } else {
      // Пауза
      final restNumber = (index + 1) ~/ 2;
      return 'Отдых $restNumber';
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
    if (widget.block.items.length <= 2)
      return; // Keep at least 2 items (1 exercise + 1 pause)

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Название блока',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) => _updateBlock(),
                  ),
                ),
                const SizedBox(width: 8),
                // Поле повторов с кнопками
                SizedBox(
                  width: 140, // Увеличили ширину
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70, // Увеличили ширину поля
                        child: TextField(
                          controller: _repeatsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Повторы',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8, // Увеличили padding
                              vertical: 12, // Увеличили вертикальный padding
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                          ), // Увеличили размер шрифта
                          onChanged: (value) => _updateBlock(),
                        ),
                      ),
                      const SizedBox(width: 8), // Увеличили расстояние
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Увеличенные кнопки со стрелками для повторов
                          SizedBox(
                            width: 32, // Увеличили ширину
                            height: 32, // Увеличили высоту
                            child: ElevatedButton(
                              onPressed: _increaseRepeats,
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
                          const SizedBox(
                            height: 4,
                          ), // Увеличили расстояние между кнопками
                          SizedBox(
                            width: 32, // Увеличили ширину
                            height: 32, // Увеличили высоту
                            child: ElevatedButton(
                              onPressed: _decreaseRepeats,
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
                ),
                const SizedBox(width: 8),
                if (widget.showDeleteButton)
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 24,
                    ), // Увеличили размер иконки
                    onPressed: widget.onDelete,
                    padding: const EdgeInsets.all(8), // Увеличили padding
                    constraints: const BoxConstraints(
                      minWidth: 40, // Увеличили минимальную ширину
                      minHeight: 40, // Увеличили минимальную высоту
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Таймеры в блоке:',
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
                    // Название таймера
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
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
                    TimeInputWidget(
                      initialSeconds: item.duration,
                      onTimeChanged: (newDuration) =>
                          _updateItemTime(index, newDuration),
                      label: 'MM:SS',
                    ),
                    const SizedBox(width: 8),
                    if (widget.block.items.length >
                        2) // Only show delete button if more than 2 items
                      IconButton(
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
                      ),
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
                    size: 20,
                  ), // Увеличили размер иконки
                  label: const Text('Добавить таймер'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ), // Увеличили padding
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
