class QuestField {
  final String title;
  final String subtitle;
  final List<String> topics;

  const QuestField({
    required this.title,
    required this.subtitle,
    required this.topics,
  });
}

const List<QuestField> questFields = [
  QuestField(
    title: 'Bilgisayar',
    subtitle: 'Yazılım, yapay zeka, güvenlik',
    topics: [
      'Kriptografi',
      'Yapay Zeka',
      'İşletim Sistemleri',
      'Veritabanı',
      'Algoritmalar',
      'Sinir Ağları',
    ],
  ),
  QuestField(
    title: 'Biyoloji',
    subtitle: 'Canlılar, hücreler, insan vücudu',
    topics: [
      'Sinir Sistemi',
      'Hücre Yapısı',
      'Genetik',
      'Bağışıklık Sistemi',
      'DNA ve RNA',
    ],
  ),
  QuestField(
    title: 'Tarih',
    subtitle: 'Olaylar, dönemler, uygarlıklar',
    topics: [
      'Antik Mısır',
      'Osmanlı Devleti',
      'I. Dünya Savaşı',
      'Fransız İhtilali',
      'Roma İmparatorluğu',
    ],
  ),
  QuestField(
    title: 'Dil',
    subtitle: 'Kelime, gramer, konuşma',
    topics: [
      'İngilizce Zamanlar',
      'Akademik Kelimeler',
      'Phrasal Verbs',
      'Essay Writing',
      'Konuşma Kalıpları',
    ],
  ),
  QuestField(
    title: 'Matematik',
    subtitle: 'Formüller, mantık, problem',
    topics: [
      'Fonksiyonlar',
      'Türev',
      'Olasılık',
      'Lineer Cebir',
      'Trigonometri',
    ],
  ),
  QuestField(
    title: 'Psikoloji',
    subtitle: 'Hafıza, motivasyon, davranış',
    topics: [
      'Hafıza Teknikleri',
      'Motivasyon',
      'Öğrenme Stilleri',
      'Bilişsel Yanlılıklar',
      'Duygusal Zeka',
    ],
  ),
];