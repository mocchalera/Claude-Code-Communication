#!/bin/bash

# 🚀 Agent間メッセージ送信スクリプト

# エージェント→tmuxターゲット マッピング
get_agent_target() {
    case "$1" in
        "president") echo "president" ;;
        "boss1") echo "multiagent:0.0" ;;
        "worker1") echo "multiagent:0.1" ;;
        "worker2") echo "multiagent:0.2" ;;
        "worker3") echo "multiagent:0.3" ;;
        "dispatcher") echo "multiagent:1.0" ;;
        "market_analyst") echo "specialist:0.0" ;;
        "ux_researcher") echo "specialist:0.1" ;;
        "integrator") echo "specialist:1.0" ;;
        "qa_tester") echo "specialist:1.1" ;;
        "ui_ux_designer") echo "specialist:0.2" ;;
        *) echo "" ;;
    esac
}

show_usage() {
    cat << EOF
🤖 Agent間メッセージ送信

使用方法:
  $0 [エージェント名] [メッセージ]
  $0 --list

利用可能エージェント:
  president      - プロジェクト統括責任者
  boss1          - チームリーダー  
  worker1        - 実行担当者A
  worker2        - 実行担当者B
  worker3        - 実行担当者C
  dispatcher     - 動的タスク割り当て
  market_analyst - 市場分析担当
  ux_researcher  - UXリサーチ担当
  ui_ux_designer - UI/UXデザイン担当
  integrator     - 統合担当
  qa_tester      - 品質保証担当

使用例:
  $0 president "指示書に従って"
  $0 boss1 "Hello World プロジェクト開始指示"
  $0 worker1 "作業完了しました"
EOF
}

# エージェント一覧表示
show_agents() {
    echo "📋 利用可能なエージェント:"
    echo "=========================="
    echo "【戦略層】"
    echo "  president      → president:0       (プロジェクト統括責任者)"
    echo "  market_analyst → specialist:0.0    (市場分析担当)"
    echo "  ux_researcher  → specialist:0.1    (UXリサーチ担当)"
    echo "  ui_ux_designer → specialist:0.2    (UI/UXデザイン担当)"
    echo ""
    echo "【管理層】"
    echo "  boss1          → multiagent:0.0    (チームリーダー)"
    echo "  dispatcher     → multiagent:1.0    (動的タスク割り当て)"
    echo ""
    echo "【実行層】"
    echo "  worker1        → multiagent:0.1    (実行担当者A)"
    echo "  worker2        → multiagent:0.2    (実行担当者B)" 
    echo "  worker3        → multiagent:0.3    (実行担当者C)"
    echo ""
    echo "【品質保証層】"
    echo "  integrator     → specialist:1.0    (統合担当)"
    echo "  qa_tester      → specialist:1.1    (品質保証担当)"
}

# ログ記録
log_send() {
    local agent="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] $agent: SENT - \"$message\"" >> logs/send_log.txt
}

# メッセージ送信
send_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        return 1
    fi
    
    return 0
}

# メイン処理
main() {
    if [[ $# -eq 0 ]]; then
        show_usage
        exit 1
    fi
    
    # --listオプション
    if [[ "$1" == "--list" ]]; then
        show_agents
        exit 0
    fi
    
    if [[ $# -lt 2 ]]; then
        show_usage
        exit 1
    fi
    
    local agent_name="$1"
    local message="$2"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: $0 --list"
        exit 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        exit 1
    fi
    
    # メッセージ送信
    send_message "$target" "$message"
    
    # ログ記録
    log_send "$agent_name" "$message"
    
    echo "✅ 送信完了: $agent_name に '$message'"
    
    return 0
}

main "$@" 