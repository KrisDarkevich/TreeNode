import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: TreeExample(),
    debugShowCheckedModeBanner: false,
  ));
}

class TreeNode {
  String title;
  bool isChecked;
  bool isExpanded;
  List<TreeNode> children;
  TreeNode? parent;

  TreeNode({
    required this.title,
    this.isChecked = false,
    this.isExpanded = false,
    this.parent,
    List<TreeNode>? children,
  }) : children = children ?? [];

  bool get hasCheckedChildren => children.any((child) => child.isChecked);
}

class TreeExample extends StatefulWidget {
  const TreeExample({super.key});

  @override
  State<TreeExample> createState() => _TreeExampleState();
}

class _TreeExampleState extends State<TreeExample> {
  TreeNode root = TreeNode(title: "Корневой элемент");
  int _counter = 1;

  void _updateParentChecks(TreeNode? node) {
    while (node != null) {
      node.isChecked = node.hasCheckedChildren;
      node = node.parent;
    }
    setState(() {});
  }

  void _toggleCheck(TreeNode node) {
    node.isChecked = !node.isChecked;
    _updateParentChecks(node.parent);
    setState(() {});
  }

  void _addChild(TreeNode node) {
    var newNode = TreeNode(title: "Элемент ${_counter++}", parent: node);
    node.children.add(newNode);
    node.isExpanded = true;
    setState(() {});
  }

  void _removeNode(TreeNode parent, TreeNode node) {
    parent.children.remove(node);
    _updateParentChecks(parent);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Дерево элементов")),
      body: ListView(
        children: [
          TreeNodeWidget(
            node: root,
            parent: null,
            onCheckToggle: _toggleCheck,
            onAddChild: _addChild,
            onRemove: _removeNode,
          ),
        ],
      ),
    );
  }
}

class TreeNodeWidget extends StatefulWidget {
  final TreeNode node;
  final TreeNode? parent;
  final Function(TreeNode) onCheckToggle;
  final Function(TreeNode) onAddChild;
  final Function(TreeNode, TreeNode) onRemove;

  const TreeNodeWidget({
    super.key,
    required this.node,
    required this.parent,
    required this.onCheckToggle,
    required this.onAddChild,
    required this.onRemove,
  });

  @override
  _TreeNodeWidgetState createState() => _TreeNodeWidgetState();
}

class _TreeNodeWidgetState extends State<TreeNodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            widget.node.children.isNotEmpty
                ? IconButton(
                    icon:
                        Icon(widget.node.isExpanded ? Icons.remove : Icons.add),
                    onPressed: () {
                      setState(() {
                        widget.node.isExpanded = !widget.node.isExpanded;
                      });
                    },
                  )
                : const SizedBox(width: 48),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: widget.node.title),
                onChanged: (value) {
                  widget.node.title = value;
                },
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            Checkbox(
              value: widget.node.isChecked,
              onChanged: (value) {
                widget.onCheckToggle(widget.node);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => widget.onAddChild(widget.node),
            ),
            if (widget.parent != null)
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => widget.onRemove(widget.parent!, widget.node),
              ),
          ],
        ),
        if (widget.node.isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Column(
              children: widget.node.children
                  .map((child) => TreeNodeWidget(
                        node: child,
                        parent: widget.node,
                        onCheckToggle: widget.onCheckToggle,
                        onAddChild: widget.onAddChild,
                        onRemove: widget.onRemove,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
