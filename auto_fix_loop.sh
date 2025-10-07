#!/bin/bash
# 自动化监控 GitHub Actions 并自动修复错误

REPO="aimin-git/android-hal-build"
API_URL="https://api.github.com/repos/$REPO/actions/runs"
WORKFLOW_FILE=".github/workflows/build_hal_full.yml"

echo "🤖 启动自动化修复循环..."
echo "仓库: $REPO"
echo "工作流: $WORKFLOW_FILE"
echo ""

MAX_ITERATIONS=50
iteration=0

while [ $iteration -lt $MAX_ITERATIONS ]; do
    iteration=$((iteration + 1))
    echo "═══════════════════════════════════════"
    echo "🔄 迭代 #$iteration"
    echo "═══════════════════════════════════════"
    
    # 等待当前运行完成
    echo "⏳ 等待构建完成..."
    sleep 30
    
    while true; do
        response=$(/usr/bin/curl -s "$API_URL?per_page=1")
        status=$(echo "$response" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
        
        if [ "$status" = "completed" ]; then
            break
        fi
        
        echo -n "."
        sleep 10
    done
    echo ""
    
    # 获取运行结果
    conclusion=$(echo "$response" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)
    run_id=$(echo "$response" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    
    echo "📊 构建结果: $conclusion (Run #$run_id)"
    
    if [ "$conclusion" = "success" ]; then
        echo "🎉 构建成功！"
        echo ""
        echo "下载编译产物:"
        echo "https://github.com/$REPO/actions/runs/$run_id"
        break
    elif [ "$conclusion" = "failure" ]; then
        echo "❌ 构建失败，正在分析日志..."
        
        # 下载日志
        logs_url="https://github.com/$REPO/actions/runs/$run_id"
        echo "📋 日志URL: $logs_url"
        
        # 打开浏览器查看日志
        open "$logs_url"
        
        echo ""
        echo "请查看日志并输入错误关键词（或输入 'quit' 退出）："
        read -r error_keyword
        
        if [ "$error_keyword" = "quit" ]; then
            echo "👋 退出自动修复循环"
            exit 0
        fi
        
        # 根据错误类型自动修复
        echo "🔧 尝试修复: $error_keyword"
        
        case "$error_keyword" in
            *"repo sync"*|*"fatal"*)
                echo "修复: repo sync 错误"
                # 在这里添加修复逻辑
                ;;
            *"No such file"*)
                echo "修复: 缺少文件"
                # 在这里添加修复逻辑
                ;;
            *"command not found"*)
                echo "修复: 命令未找到"
                # 在这里添加修复逻辑
                ;;
            *)
                echo "未知错误类型，需要手动修复"
                echo "请直接编辑 $WORKFLOW_FILE 然后按 Enter 继续..."
                read
                ;;
        esac
        
        # 提交修复
        echo "💾 提交修复..."
        git add "$WORKFLOW_FILE"
        git commit -m "CI: auto-fix iteration #$iteration - $error_keyword"
        git push origin main
        
        echo "✅ 修复已提交，等待新构建..."
        sleep 10
    else
        echo "⚠️ 未知状态: $conclusion"
        sleep 30
    fi
done

if [ $iteration -ge $MAX_ITERATIONS ]; then
    echo "⚠️ 达到最大迭代次数 ($MAX_ITERATIONS)"
fi

