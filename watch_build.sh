#!/bin/bash
# 简化的实时监控脚本

REPO="aimin-git/android-hal-build"
API_URL="https://api.github.com/repos/$REPO/actions/runs"

echo "🔍 实时监控 GitHub Actions 构建状态"
echo "仓库: $REPO"
echo "按 Ctrl+C 停止监控"
echo ""

while true; do
    response=$(/usr/bin/curl -s "$API_URL?per_page=1")
    
    status=$(echo "$response" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
    conclusion=$(echo "$response" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)
    run_number=$(echo "$response" | grep -o '"run_number":[0-9]*' | head -1 | cut -d':' -f2)
    run_id=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    created_at=$(echo "$response" | grep -o '"created_at":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    # 清屏并显示
    clear
    echo "═══════════════════════════════════════════════════════════"
    echo "  GitHub Actions 实时监控"
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    echo "📦 仓库: $REPO"
    echo "🔢 运行编号: #$run_number"
    echo "🆔 运行ID: $run_id"
    echo "📅 创建时间: $created_at"
    echo ""
    
    if [ "$status" = "queued" ]; then
        echo "⏸️  状态: 排队中..."
    elif [ "$status" = "in_progress" ]; then
        echo "⚙️  状态: 正在运行..."
    elif [ "$status" = "completed" ]; then
        if [ "$conclusion" = "success" ]; then
            echo "✅ 状态: 成功！"
            echo ""
            echo "🎉 编译成功！下载产物:"
            echo "https://github.com/$REPO/actions/runs/$run_id"
            echo ""
            echo "按 Enter 退出或等待自动退出..."
            sleep 10
            break
        elif [ "$conclusion" = "failure" ]; then
            echo "❌ 状态: 失败"
            echo ""
            echo "📋 查看日志:"
            echo "https://github.com/$REPO/actions/runs/$run_id"
            echo ""
            echo "⏳ 等待30秒后继续监控..."
            sleep 30
        else
            echo "⚠️  状态: $conclusion"
        fi
    else
        echo "❓ 状态: $status"
    fi
    
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "刷新中... (每10秒)"
    sleep 10
done

