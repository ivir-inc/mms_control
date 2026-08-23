/*
 * Copyright 2026 IVIR Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ivir.mpif.common.tree;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Supplier;

public class TreeBuilder<T> {

    public static class TreeNode<T> {
        private T value;
        private TreeNode<T> parent;
        private List<TreeNode<T>> children = new ArrayList<>();

        public TreeNode(T value) {
            this.value = value;
        }

        public T getValue() {
            return value;
        }

        public TreeNode<T> getParent() {
            return parent;
        }

        public List<TreeNode<T>> getChildren() {
            return children;
        }

        private void addChild(TreeNode<T> child) {
            children.add(child);
            child.parent = this;
        }

        @Override
        public String toString() {
            return value.toString();
        }
    }

    private TreeNode<T> root;
    private TreeNode<T> current;
    private int nodeCount = 0;

    public TreeBuilder(T rootValue) {
        root = new TreeNode<>(rootValue);
        current = root;
        nodeCount++;
    }

    public TreeBuilder<T> addChild(T value) {
        TreeNode<T> child = new TreeNode<>(value);
        current.addChild(child);
        current = child;
        nodeCount++;
        return this;
    }

    public TreeBuilder<T> addChildIfTrue(boolean condition, Supplier<T> supplier){
        if(condition){
            addChild(supplier.get());
        }
        return this;
    }

    public TreeBuilder<T> addSibling(T value) {
        if (current.parent == null) {
            throw new IllegalStateException("Root node cannot have siblings.");
        }
        TreeNode<T> sibling = new TreeNode<>(value);
        current.parent.addChild(sibling);
        current = sibling;
        nodeCount++;
        return this;
    }

    public TreeBuilder<T> addSiblingIfTrue(boolean condition, Supplier<T> supplier){
        if(condition){
            addSibling(supplier.get());
        }
        return this;
    }

    public TreeBuilder<T> up() {
        if (current.parent != null) {
            current = current.parent;
        }
        return this;
    }

    public int size(){
        return this.nodeCount;
    }

    public TreeNode<T> getRoot() {
        return root;
    }

    // Pretty print the tree
    public static <T> void printTree(TreeNode<T> node) {
        printTree(node, "", true);
    }

    private static <T> void printTree(TreeNode<T> node, String prefix, boolean isTail) {
        System.out.println(prefix + (isTail ? "\\-- " : "|-- ") + node.getValue());
        List<TreeNode<T>> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            boolean last = (i == children.size() - 1);
            printTree(children.get(i), prefix + (isTail ? "    " : "|   "), last);
        }
    }

    public static <T> String treeString(TreeNode<T> node){
        StringBuilder strBuilder = new StringBuilder();
        treeString(strBuilder, node, "", true);
        return strBuilder.toString();
    }

    public static <T> void treeString(StringBuilder strBuilder, TreeNode<T> node, String prefix, boolean isTail){
        strBuilder.append("\n").append(prefix + (isTail ? "\\-- " : "|-- ") + node.getValue());
        List<TreeNode<T>> children = node.getChildren();
        for (int i = 0; i < children.size(); i++) {
            boolean last = (i == children.size() - 1);
            treeString(strBuilder, children.get(i), prefix + (isTail ? "    " : "|   "), last);
        }
    }
}
