import '../models/adventure_models.dart';

List<AdventureChapter> buildMockAdventure({
  required String topic,
  required String modeTitle,
}) {
  final chapters = <AdventureChapter>[];

  for (int i = 1; i <= 5; i++) {
    chapters.add(
      AdventureChapter(
        id: i,
        title: _normalTitle(topic, modeTitle, i),
        subtitle: 'Öğrenme adımı',
        story:
            '$modeTitle dünyasında $topic konusunun ${i}. görevi açılıyor. Bu görev seni final mini quiz için hazırlayacak.',
        explanation:
            '$topic konusunu öğrenirken bilgiyi küçük parçalara ayırmak önemlidir. Bu bölümde konunun bir parçasını daha anlaşılır hale getiriyoruz. Önce kavramın ne işe yaradığını düşünmelisin. Sonra bu kavramın gerçek kullanımını hayal etmelisin. Konuyu sadece ezberlemek yerine, neden gerekli olduğunu anlamak daha kalıcı öğrenme sağlar. Bu görevdeki amaç seni finaldeki sorulara hazırlamaktır.',
        memoryTip:
            'Bu konuyu bir haritanın parçası gibi düşün. Her görev final kapısına giden yolda bir işaret taşıdır.',
        question: '$topic öğrenirken en doğru yaklaşım nedir?',
        options: const [
          'Konuyu parçalara ayırarak anlamak',
          'Sadece ezberlemek',
          'Hiç tekrar etmemek',
          'Soruları atlamak',
        ],
        correctIndex: 0,
        isBoss: false,
        finalQuiz: const [],
      ),
    );
  }

  chapters.add(
    AdventureChapter(
      id: 6,
      title: _bossTitle(topic, modeTitle),
      subtitle: 'Final Mini Quiz',
      story:
          '$modeTitle dünyasının son kapısı açıldı. Artık $topic konusundaki öğrendiklerini 5 soruluk final mini quiz ile kanıtlamalısın.',
      explanation:
          'Final mini quiz, önceki görevlerde öğrendiğin bilgileri birlikte kullanmanı sağlar. Bu bölümde sadece tek bir tanımı bilmen yeterli değildir. Konunun temel amacını, kullanım şeklini ve önemli kavramlarını ayırt etmelisin. Her soru, öğrendiğin bir parçayı kontrol eder. Yanlış cevaplar sana hangi noktayı tekrar etmen gerektiğini gösterir. Soruları çözerken acele etmeden seçenekleri karşılaştırmalısın.',
      memoryTip:
          'Final boss, öğrendiğin tüm küçük kapıların birleştiği büyük sınavdır.',
      question: '$topic finalinde hangi yaklaşım daha doğrudur?',
      options: const [
        'Öğrendiğin tüm bağlantıları kullanmak',
        'Sadece tahmin etmek',
        'Hiç düşünmeden seçmek',
        'Konuyu atlamak',
      ],
      correctIndex: 0,
      isBoss: true,
      finalQuiz: [
        QuizQuestion(
          question: 'Bir konuyu kalıcı öğrenmek için ilk adım ne olmalıdır?',
          options: [
            'Temel kavramları anlamak',
            'Sadece ezber yapmak',
            'Hiç soru çözmemek',
            'Not almamak',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Öğrenilen bilgiyi güçlendiren şey nedir?',
          options: [
            'Uygulama ve örnek çözmek',
            'Konuyu tamamen bırakmak',
            'Yanlışları görmezden gelmek',
            'Sadece başlık okumak',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Hafıza ipuçları neden kullanılır?',
          options: [
            'Bilgiyi daha kolay hatırlamak için',
            'Bilgiyi silmek için',
            'Konuyu zorlaştırmak için',
            'Soruları azaltmak için',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Mini quiz neyi kontrol eder?',
          options: [
            'Konunun anlaşılıp anlaşılmadığını',
            'Sadece ekran rengini',
            'Uygulamanın hızını',
            'İnternet bağlantısını',
          ],
          correctIndex: 0,
        ),
        QuizQuestion(
          question: 'Yanlış cevaplar öğrenmede ne işe yarar?',
          options: [
            'Eksik kalan noktayı gösterir',
            'Öğrenmeyi tamamen bitirir',
            'Her zaman doğru kabul edilir',
            'Konuyu gereksiz yapar',
          ],
          correctIndex: 0,
        ),
      ],
    ),
  );

  return chapters;
}

String _normalTitle(String topic, String mode, int id) {
  if (mode.contains('Dedektif')) return '$topic İpucu Dosyası $id';
  if (mode.contains('Uzay')) return '$topic Görev Noktası $id';
  if (mode.contains('Antik')) return '$topic Antik Kapısı $id';
  if (mode.contains('Laboratuvar')) return '$topic Deney Aşaması $id';
  if (mode.contains('Korku')) return '$topic Kilitli Oda $id';
  return '$topic Büyülü Kapısı $id';
}

String _bossTitle(String topic, String mode) {
  if (mode.contains('Dedektif')) return '$topic Final Davası';
  if (mode.contains('Uzay')) return '$topic Galaktik Sınavı';
  if (mode.contains('Antik')) return '$topic Antik Muhafızı';
  if (mode.contains('Laboratuvar')) return '$topic Büyük Deneyi';
  if (mode.contains('Korku')) return '$topic Karanlık Finali';
  return '$topic Ejderha Sınavı';
}