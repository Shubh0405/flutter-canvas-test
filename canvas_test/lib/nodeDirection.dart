enum NodeDirection {
  centerToLeft,
  centerToRight,
  leftToRight,
  rightToLeft,
  leftToCenter,
  rightToCenter
}

class NodeDirectionGenerator {
  List<NodeDirection> generate(int nodeCount) {
    List<NodeDirection> directionList = [];

    List<NodeDirection> directionSequence = [
      NodeDirection.centerToLeft,
      NodeDirection.leftToRight,
      NodeDirection.rightToCenter,
      NodeDirection.centerToRight,
      NodeDirection.rightToLeft,
      NodeDirection.leftToRight,
      NodeDirection.rightToCenter
    ];

    // for (int i = 1; i < nodeCount; i++) {
    //   switch (directionList[i - 1]) {
    //     case NodeDirection.centerToLeft:
    //     case NodeDirection.rightToLeft:
    //       if (i != nodeCount - 1) {
    //         directionList.add(NodeDirection.leftToRight);
    //       } else {
    //         directionList.add(NodeDirection.leftToCenter);
    //       }

    //     case NodeDirection.centerToRight:
    //     case NodeDirection.leftToRight:
    //       if (i != nodeCount - 1) {
    //         directionList.add(NodeDirection.rightToLeft);
    //       } else {
    //         directionList.add(NodeDirection.rightToCenter);
    //       }

    //     default:
    //       break;
    //   }
    // }

    for (int i = 0; i < nodeCount; i++) {
      directionList.add(directionSequence[i % 7]);
    }

    return directionList;
  }
}
