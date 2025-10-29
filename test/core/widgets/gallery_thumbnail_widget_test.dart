import 'package:auteurly/core/widgets/gallery_thumbnail_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GalleryThumbnailWidget Tests', () {
    testWidgets('should display image thumbnail for image type',
        (WidgetTester tester) async {
      // Arrange
      final item = {
        'type': 'image',
        'storageUrl': 'https://example.com/image.jpg',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryThumbnailWidget(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should display video placeholder for video type',
        (WidgetTester tester) async {
      // Arrange
      final item = {
        'type': 'video',
        'storageUrl': 'https://example.com/video.mp4',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryThumbnailWidget(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('should display PDF icon for pdf type',
        (WidgetTester tester) async {
      // Arrange
      final item = {
        'type': 'pdf',
        'storageUrl': 'https://example.com/document.pdf',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryThumbnailWidget(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.picture_as_pdf_outlined), findsOneWidget);
    });

    testWidgets('should display file icon for other types',
        (WidgetTester tester) async {
      // Arrange
      final item = {
        'type': 'other',
        'storageUrl': 'https://example.com/file.txt',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryThumbnailWidget(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final item = {
        'type': 'image',
        'storageUrl': 'https://example.com/image.jpg',
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryThumbnailWidget(
              item: item,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Wait for widget to render
      await tester.pump();
      
      // Tap on the Image widget inside (it's the content of Card which is inside GestureDetector)
      // Using descendant to find Image specifically within our GalleryThumbnailWidget
      final imageFinder = find.descendant(
        of: find.byType(GalleryThumbnailWidget),
        matching: find.byType(Image),
      );
      if (imageFinder.evaluate().isNotEmpty) {
        await tester.tap(imageFinder, warnIfMissed: false);
      } else {
        // Fallback: tap on Container if Image isn't loaded yet
        final containerFinder = find.descendant(
          of: find.byType(GalleryThumbnailWidget),
          matching: find.byType(Container),
        );
        await tester.tap(containerFinder.first, warnIfMissed: false);
      }
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should handle missing type with default',
        (WidgetTester tester) async {
      // Arrange
      final item = {
        'storageUrl': 'https://example.com/file.txt',
        // type is missing
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GalleryThumbnailWidget(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - should default to 'other' type
      expect(find.byIcon(Icons.insert_drive_file_outlined), findsOneWidget);
    });
  });
}
