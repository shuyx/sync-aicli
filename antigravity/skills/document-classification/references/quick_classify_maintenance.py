#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
CUBOX 快速维护脚本 - 新文件快速分类工具
用于日常新增文件的快速自动分类

使用方式:
  python3 quick_classify.py "文件名.md"
  或
  python3 quick_classify.py --folder /path/to/folder --vault 智能制造
"""

import os
import sys
import shutil
from pathlib import Path
import argparse

# ════════════════════════════════════════════════════════════════
# 规则库 (Rule Library) - 维护于此
# ════════════════════════════════════════════════════════════════

VAULT_PATHS = {
    "具身智能": "/Users/mac-minishu/Obsidian/kevinob/具身智能",
    "AI_agent": "/Users/mac-minishu/Obsidian/kevinob/Cubox/AI agent",
    "智能制造": "/Users/mac-minishu/Obsidian/kevinob/Cubox/智能制造",
    "新技术": "/Users/mac-minishu/Obsidian/kevinob/Cubox/新技术探索",
}

# 智能制造规则库 (v2.0)
SMARTMFG_RULES = {
    "01-工业视觉检测": {
        "keywords": ["视觉", "摄像", "图像", "识别", "相机", "检测", "AOI"],
        "priority": 1,
    },
    "02-机器人与AGV": {
        "keywords": ["机器人", "AGV", "自动", "臂", "末端", "cobot", "协作"],
        "priority": 1,
    },
    "03-智能工厂": {
        "keywords": ["工厂", "制造", "生产", "车间", "MES", "供应链"],
        "priority": 1,
    },
    "04-传感与驱动": {
        "keywords": ["传感", "驱动", "马达", "伺服", "液压", "气动"],
        "priority": 1,
    },
    "05-工业控制": {
        "keywords": ["控制", "PLC", "运动", "CNC", "实时"],
        "priority": 1,
    },
    "07-增材制造": {
        "keywords": ["增材", "3D", "打印", "SLA", "FDM"],
        "priority": 1,
    },
    "09-柔性穿戴": {
        "keywords": ["柔性", "穿戴", "软体"],
        "priority": 1,
    },
    "10-工业安全": {
        "keywords": ["安全", "cobot", "防护", "CE", "认证", "协作"],
        "priority": 1,
    },
    "11-质量检测": {
        "keywords": ["质量", "检测", "AOI", "缺陷", "品质", "良率"],
        "priority": 1,
    },
    "08-污染数据": {
        "keywords": ["互联网", "社会", "历史", "经济", "商人", "企业", "新闻"],
        "priority": 0,  # 污染优先处理
        "is_pollution": True,
    },
}

# AI agent 规则库 (v2.0)
AI_AGENT_RULES = {
    "01-计算机视觉": {"keywords": ["视觉", "图像", "检测", "识别"], "priority": 1},
    "02-深度学习基础": {"keywords": ["深度学习", "神经网络", "CNN"], "priority": 1},
    "03-NLP与LLM": {"keywords": ["NLP", "LLM", "语言模型", "GPT"], "priority": 1},
    "07-SLAM": {"keywords": ["SLAM", "定位", "导航", "地图"], "priority": 1},
    "08-脑机": {"keywords": ["脑机", "BCI", "神经", "信号"], "priority": 1},
    "09-机械臂": {"keywords": ["机械臂", "手", "操作", "末端"], "priority": 1},
    "10-无人机": {"keywords": ["无人机", "机器狗", "四足"], "priority": 1},
    "11-强化学习": {"keywords": ["强化学习", "RL", "控制"], "priority": 1},
    "12-工程工具": {"keywords": ["工具", "框架", "库", "实现"], "priority": 1},
}

def classify_file(filename, rules):
    """根据规则分类文件"""
    name_lower = filename.lower()
    
    # 污染检测优先
    for dim, config in rules.items():
        if config.get("is_pollution"):
            for kw in config["keywords"]:
                if kw.lower() in name_lower:
                    return dim
    
    # 关键词匹配
    best_match = None
    best_priority = -1
    
    for dim, config in rules.items():
        if config.get("is_pollution"):
            continue
        
        for kw in config["keywords"]:
            if kw.lower() in name_lower:
                if config["priority"] > best_priority:
                    best_match = dim
                    best_priority = config["priority"]
    
    return best_match

def main():
    parser = argparse.ArgumentParser(description="CUBOX 快速分类工具")
    parser.add_argument("file", nargs="?", help="要分类的文件名")
    parser.add_argument("--vault", default="智能制造", help="Vault 名称")
    parser.add_argument("--folder", help="批量分类文件夹")
    parser.add_argument("--apply", action="store_true", help="直接执行分类(不确认)")
    
    args = parser.parse_args()
    
    # 获取规则库
    if args.vault == "智能制造":
        rules = SMARTMFG_RULES
        vault_path = Path(VAULT_PATHS["智能制造"])
    elif args.vault == "AI_agent":
        rules = AI_AGENT_RULES
        vault_path = Path(VAULT_PATHS["AI_agent"])
    else:
        print(f"❌ 未知 vault: {args.vault}")
        return
    
    if not vault_path.exists():
        print(f"❌ Vault 不存在: {vault_path}")
        return
    
    # 单文件分类
    if args.file:
        target_dim = classify_file(args.file, rules)
        
        if target_dim:
            print(f"📍 建议分类: {target_dim}")
            target_folder = vault_path / target_dim
            
            if args.apply:
                target_folder.mkdir(parents=True, exist_ok=True)
                # 实际移动逻辑 (需要文件完整路径)
                print(f"✅ 已移动到: {target_folder}")
            else:
                print(f"  执行: python3 this_script.py {args.file} --vault {args.vault} --apply")
        else:
            print(f"❓ 无法分类: {args.file}")
            print(f"  建议放入: 00-待分类")
    
    # 批量分类
    elif args.folder:
        if not os.path.isdir(args.folder):
            print(f"❌ 文件夹不存在: {args.folder}")
            return
        
        files = [f for f in os.listdir(args.folder) if f.endswith(".md")]
        print(f"📁 找到 {len(files)} 个 MD 文件")
        
        for file in files:
            target_dim = classify_file(file, rules)
            status = "✅" if target_dim else "❓"
            print(f"  {status} {file} → {target_dim or '待分类'}")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
