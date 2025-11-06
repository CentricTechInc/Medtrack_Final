import 'package:flutter/material.dart';

class SharedDocumentWidget extends StatelessWidget {
  final String fileUrl;

  const SharedDocumentWidget({
    super.key,
    required this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    print(fileUrl);
    // Check if the URL is empty
    if (fileUrl.isEmpty || fileUrl == 'null') {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'No Documents',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Extract file extension from the URL
    final String fileExtension = fileUrl.split('.').last.toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Shared Document',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (fileExtension != 'pdf')
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  child: InteractiveViewer(
                    child: Image.network(
                      fileUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: NetworkImage(fileUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'PDF files are not supported for preview.',
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
