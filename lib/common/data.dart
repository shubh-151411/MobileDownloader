class DownloadItems {
  static const videos = [
    DownloadItem(
      name: 'Big Buck Bunny',
      url:
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    ),
    DownloadItem(
      name: 'Elephant Dream',
      url:
          'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
    ),
  ];
}

class DownloadItem {
  const DownloadItem({required this.name, required this.url});

  final String name;
  final String url;
}
