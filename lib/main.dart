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

  TreeNode({
    required this.title,
    this.isChecked = false,
    this.isExpanded = false,
    List<TreeNode>? children,
  }) : children = children ?? [];

  TreeNode? get parent => null;
}

class TreeExample extends StatefulWidget {
  const TreeExample({super.key});

  @override
  State<TreeExample> createState() => _TreeExampleState();
}

class _TreeExampleState extends State<TreeExample> {
  TreeNode root = TreeNode(title: "Корневой элемент");
  int _counter = 1;

  void _updateParentChecks(TreeNode node) {
    if (node.children.isEmpty) return;

    bool allChecked = node.children.every((child) => child.isChecked);
    node.isChecked = allChecked;
    setState(() {});
  }

  void _toggleCheck(TreeNode node) {
    node.isChecked = !node.isChecked;
    for (var child in node.children) {
      child.isChecked = node.isChecked;
    }
    setState(() {});
  }

  void _addChild(TreeNode node) {
    node.children.add(TreeNode(title: "Элемент ${_counter++}"));
    node.isExpanded = true;
    setState(() {});
  }

  void _removeNode(TreeNode parent, TreeNode node) {
    parent.children.remove(node);
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
            updateParentCheck: _updateParentChecks,
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
  final Function(TreeNode) updateParentCheck;
  final Function(TreeNode) onAddChild;
  final Function(TreeNode, TreeNode) onRemove;

  const TreeNodeWidget({
    super.key,
    required this.node,
    required this.parent,
    required this.onCheckToggle,
    required this.onAddChild,
    required this.onRemove,
    required this.updateParentCheck,
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
                if (widget.parent != null) {
                  widget.updateParentCheck(widget.parent!);
                }
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
                        updateParentCheck: widget.updateParentCheck,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}
