// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:torn_pda/models/chaining/target_model.dart';
import 'package:torn_pda/providers/targets_provider.dart';
import 'package:torn_pda/widgets/chaining/target_card.dart';

class TargetsList extends StatelessWidget {
  final List<TargetModel> targets;

  TargetsList({@required this.targets});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return ListView(
        shrinkWrap: true,
        children: getChildrenTargets(context),
      );
    } else {
      return ListView(
        children: getChildrenTargets(context),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      );
    }
  }

  List<Widget> getChildrenTargets(BuildContext _) {
    var targetsProvider = Provider.of<TargetsProvider>(_, listen: false);
    String filter = targetsProvider.currentWordFilter;
    List<Widget> filteredCards = <Widget>[];
    for (var thisTarget in targets) {
      if (thisTarget.name.toUpperCase().contains(filter.toUpperCase())) {
        if (!targetsProvider.currentColorFilterOut.contains(thisTarget.personalNoteColor)) {
          filteredCards.add(TargetCard(key: UniqueKey(), targetModel: thisTarget));
        }
      }
    }
    // Avoid collisions with SnackBar
    filteredCards.add(SizedBox(height: 50));
    return filteredCards;
  }
}
