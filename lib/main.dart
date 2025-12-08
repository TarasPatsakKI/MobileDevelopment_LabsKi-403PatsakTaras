import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор Настрою',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MoodCalculator(),
    );
  }
}

class MoodCalculator extends StatefulWidget {
  const MoodCalculator({super.key});

  @override
  State<MoodCalculator> createState() => _MoodCalculatorState();
}

class _MoodCalculatorState extends State<MoodCalculator> {
  int _moodScore = 0;
  final TextEditingController _controller = TextEditingController();
  String _message = 'Введіть щось, щоб змінити настрій!';

  void _processInput(String input) {
    setState(() {
      final lowerInput = input.toLowerCase().trim();

      final number = int.tryParse(input);
      if (number != null) {
        _moodScore += number;
        _message = 'Додано $number балів!';
        return;
      }

      if (lowerInput == 'reset' || lowerInput == 'скинути') {
        _moodScore = 0;
        _message = '🔄 Настрій скинуто!';
        return;
      }

      if (_isPositiveWord(lowerInput)) {
        _moodScore += 10;
        _message = '😊 +10 балів за позитив!';
        return;
      }

      if (_isNegativeWord(lowerInput)) {
        _moodScore -= 10;
        _message = '😢 -10 балів за негатив...';
        return;
      }

      _message = '❓ Не розумію цього слова';
    });

    _controller.clear();
  }

  bool _isPositiveWord(String input) {
    const positiveWords = [
      'happy',
      'smile',
      'good',
      'щасливий',
      'радість',
    ];
    return positiveWords.any(input.contains);
  }

  bool _isNegativeWord(String input) {
    const negativeWords = ['sad', 'bad', 'angry', 'сумний', 'злий'];
    return negativeWords.any(input.contains);
  }

  Color _getBackgroundColor() {
    if (_moodScore > 50) {
      return Colors.green.shade100;
    }
    if (_moodScore > 20) {
      return Colors.lightGreen.shade50;
    }
    if (_moodScore < -20) {
      return Colors.red.shade50;
    }
    if (_moodScore < 0) {
      return Colors.orange.shade50;
    }
    return Colors.grey.shade50;
  }

  String _getMoodEmoji() {
    if (_moodScore > 50) return '🎉';
    if (_moodScore > 20) return '😊';
    if (_moodScore > 0) return '🙂';
    if (_moodScore > -20) return '😐';
    if (_moodScore > -50) return '😔';
    return '😢';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        title: const Text('Калькулятор Настрою'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getMoodEmoji(),
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              'Рівень настрою: $_moodScore',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _message,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Введіть число або слово',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _processInput(_controller.text);
                    }
                  },
                ),
              ),
              onSubmitted: _processInput,
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '💡 Підказки:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Введіть число (напр. 5 або -3)'),
                    Text('• Напишіть "happy" або "smile" (+10)'),
                    Text('• Напишіть "sad" або "angry" (-10)'),
                    Text('• Напишіть "reset" для обнулення'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
