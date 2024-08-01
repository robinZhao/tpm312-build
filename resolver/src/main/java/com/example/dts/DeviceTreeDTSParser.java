package com.example.dts;

import java.io.BufferedReader;

import java.io.FileReader;

import java.io.IOException;

import java.io.PrintStream;

import java.util.ArrayList;

import java.util.Comparator;

import java.util.HashMap;

import java.util.List;

import java.util.Map;

import java.util.Map.Entry;

class DeviceTreeNode {

    Map<String, Object> properties = new HashMap<>();

    public void addProperty(String property, String value) {
        properties.put(property.trim(), value);
    }

    public void addProperty(String property, DeviceTreeNode node) {
        properties.put(property.trim(), node);
    }

}

public class DeviceTreeDTSParser {

    public static void main(String[] args) {
        //String path = "F:/rk3399/tftp/rk-kernel1-linux-modify.dts";
        String path = "rk3399-tpm3120.dts";
        try (BufferedReader reader = new BufferedReader(new FileReader(path))) {
            DeviceTreeNode rootNode = new DeviceTreeNode();
            parseDTSStructure(reader, rootNode, "");
            // System.out.println(rootNode.properties.size());
            printNode(new PrintStream("rk3399-tpm3121.dts"), rootNode, 0); // 打印整个设备树结构，仅用于示例
        } catch (IOException e) {
            e.printStackTrace();
        }

    }

    private static void parseDTSStructure(BufferedReader reader, DeviceTreeNode currentNode, String prefixLine)
            throws IOException {

        String line = prefixLine;
        String l;
        boolean comment = false;

        while ((l = reader.readLine()) != null) {
            l = l.replaceAll("/\\*.*\\*/", "");
            l = l.trim();
            if (l.startsWith("#include") || l.startsWith("//")) {
                continue;
            }
            if (l.endsWith("*/") && l.startsWith("/*")) {
                continue;
            }
            if (comment && l.endsWith("*/")) {
                comment = false;
                continue;
            }
            if (!comment && l.startsWith("/*")) {
                comment = true;
                continue;
            }
            if (comment) {
                continue;
            }
            line = line + l;
            if (!line.trim().endsWith(";") && !line.trim().endsWith("{")) {
                continue;
            }
            if (line.trim().contains("{")) {
                String[] arr = line.split("\\{");
                String name = arr[0];
                DeviceTreeNode newNode = new DeviceTreeNode();
                currentNode.addProperty(name, newNode);
                parseDTSStructure(reader, newNode, arr.length > 1 ? arr[1] : ""); //
            } else if (line.trim().contains("}")) {
                if(!line.trim().equals("};")){
                    System.out.println(line);
                }
                return; // 遇到右括号，返回上一层
            } else if (!line.trim().isEmpty()) {
                if (line.trim().contains("=")) {
                    int idx = line.indexOf("=");
                    try {
                        currentNode.addProperty(line.substring(0, idx).trim(), line.substring(idx + 1).trim());
                    } catch (Exception e) {
                        e.printStackTrace();
                        System.out.println(line);
                    }
                } else {
                    currentNode.addProperty(line.trim(), "");
                }
            }
            line = "";
        }
    }

    private static void printSpace(PrintStream pw, int depth) {
        for (int i = 0; i <= depth; i++) {
            pw.print(" ");
        }
    }

    private static void printNode(PrintStream pw, DeviceTreeNode node, final int depth) {
        List<Map.Entry<String, Object>> entList = new ArrayList<>(node.properties.entrySet());
        entList.sort(new Comparator<Map.Entry<String, Object>>() {
            @Override
            public int compare(Entry<String, Object> o1, Entry<String, Object> o2) {
                if (o1.getKey().startsWith("&") && !o2.getKey().startsWith("&")) {
                    return 1;
                }

                if (!o1.getKey().startsWith("&") && o2.getKey().startsWith("&")) {
                    return -1;
                }

                if (DeviceTreeNode.class.isInstance(o1.getValue()) && !DeviceTreeNode.class.isInstance(o2.getValue())) {
                    return 1;
                }

                if (DeviceTreeNode.class.isInstance(o2.getValue()) && !DeviceTreeNode.class.isInstance(o1.getValue())) {
                    return -1;
                }
                return o1.getKey().compareTo(o2.getKey());
            }
        });

        entList.forEach((Map.Entry<String, Object> it) -> {
            String k = it.getKey();
            Object v = it.getValue();
            printSpace(pw, depth);
            if (v instanceof DeviceTreeNode) {
                pw.println(k + "{");
                int nextDepth = depth + 1;
                printNode(pw, (DeviceTreeNode) v, ++nextDepth);
                printSpace(pw, depth);
                pw.println("};");
            } else {
                if (v == null || ((String) v).trim().length() == 0) {
                    pw.println(k);
                } else {
                    pw.println(k + " = " + v);
                }
            }
        });
    }
}
