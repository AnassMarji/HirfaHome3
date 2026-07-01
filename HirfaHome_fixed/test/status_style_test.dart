// ═══ FILE: test/status_style_test.dart ═══
//
// Unit tests for the StatusStyle utility class.
// Verifies that each demande status maps to the correct visual style
// (foreground, background, label, icon) and that the fallback
// for unknown statuses is sensible.
//
// Run: flutter test test/status_style_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hirfahome/utils/status_style.dart';

void main() {
  group('StatusStyle.forStatus', () {
    test('envoye retourne un style avec icône send', () {
      final style = StatusStyle.forStatus('envoye');
      expect(style.icon, Icons.send_rounded);
      expect(style.foreground, isA<Color>());
      expect(style.background, isA<Color>());
    });

    test('accepte retourne un style avec icône check', () {
      final style = StatusStyle.forStatus('accepte');
      expect(style.icon, Icons.check_circle_outline_rounded);
    });

    test('en_cours retourne un style avec icône sablier', () {
      final style = StatusStyle.forStatus('en_cours');
      expect(style.icon, Icons.hourglass_top_rounded);
    });

    test('termine retourne un style avec icône tâche OK', () {
      final style = StatusStyle.forStatus('termine');
      expect(style.icon, Icons.task_alt_rounded);
    });

    test('refuse retourne un style avec icône annulation', () {
      final style = StatusStyle.forStatus('refuse');
      expect(style.icon, Icons.cancel_rounded);
    });

    test('statut inconnu retourne un style par défaut (icône help)', () {
      final style = StatusStyle.forStatus('unknown_status');
      expect(style.icon, Icons.help_outline_rounded);
    });

    test('chaque statut a un label non-vide en français', () {
      for (final s in ['envoye', 'accepte', 'en_cours', 'termine', 'refuse']) {
        final style = StatusStyle.forStatus(s);
        expect(style.label('fr'), isNotEmpty,
            reason: 'Le label FR pour "$s" ne doit pas être vide');
      }
    });

    test('chaque statut a un label non-vide en arabe', () {
      for (final s in ['envoye', 'accepte', 'en_cours', 'termine', 'refuse']) {
        final style = StatusStyle.forStatus(s);
        expect(style.label('ar'), isNotEmpty,
            reason: 'Le label AR pour "$s" ne doit pas être vide');
      }
    });

    test('le label FR et AR sont différents pour chaque statut', () {
      for (final s in ['envoye', 'accepte', 'en_cours', 'termine', 'refuse']) {
        final style = StatusStyle.forStatus(s);
        expect(style.label('fr'), isNot(equals(style.label('ar'))),
            reason: 'Les labels FR et AR pour "$s" doivent être différents');
      }
    });

    test('les couleurs foreground et background sont distinctes', () {
      for (final s in ['envoye', 'accepte', 'en_cours', 'termine', 'refuse']) {
        final style = StatusStyle.forStatus(s);
        expect(style.foreground, isNot(equals(style.background)),
            reason: 'Foreground et background pour "$s" doivent contraster');
      }
    });
  });
}
