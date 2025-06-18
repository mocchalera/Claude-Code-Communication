#!/bin/bash

# 🚀 対話型AIエージェントチーム構築スクリプト

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# プロジェクトタイプ定義
declare -A PROJECT_TYPES=(
    ["web"]="Webアプリケーション開発"
    ["api"]="API/バックエンド開発"
    ["data"]="データ分析・AI/ML"
    ["mobile"]="モバイルアプリ開発"
    ["devops"]="DevOps/インフラ構築"
    ["general"]="汎用開発プロジェクト"
)

# エージェント設定
declare -A AGENT_CONFIGS=(
    # 必須エージェント
    ["president"]="president:0:戦略層:プロジェクト統括責任者"
    ["boss1"]="multiagent:0.0:管理層:チームリーダー"
    
    # オプショナルエージェント
    ["market_analyst"]="specialist:0.0:戦略層:市場分析担当"
    ["ux_researcher"]="specialist:0.1:戦略層:UXリサーチ担当"
    ["dispatcher"]="multiagent:1.0:管理層:動的タスク割り当て"
    ["worker1"]="multiagent:0.1:実行層:実行担当者A"
    ["worker2"]="multiagent:0.2:実行層:実行担当者B"
    ["worker3"]="multiagent:0.3:実行層:実行担当者C"
    ["integrator"]="specialist:1.0:品質保証層:統合担当"
    ["qa_tester"]="specialist:1.1:品質保証層:品質保証担当"
)

# ヘッダー表示
show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🤖 AIエージェントチーム構築ウィザード      ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

# プロジェクト規模選択
select_project_scale() {
    echo -e "${YELLOW}📊 プロジェクトの規模を選択してください:${NC}"
    echo ""
    echo "  1) Small  - 小規模プロジェクト (1-3人月)"
    echo "  2) Medium - 中規模プロジェクト (3-10人月)"
    echo "  3) Large  - 大規模プロジェクト (10人月以上)"
    echo ""
    read -p "選択 (1-3): " scale_choice
    
    case $scale_choice in
        1) PROJECT_SCALE="small" ;;
        2) PROJECT_SCALE="medium" ;;
        3) PROJECT_SCALE="large" ;;
        *) echo -e "${RED}無効な選択です${NC}"; exit 1 ;;
    esac
}

# プロジェクトタイプ選択
select_project_type() {
    echo ""
    echo -e "${YELLOW}🔧 プロジェクトのタイプを選択してください:${NC}"
    echo ""
    
    local i=1
    declare -A type_map
    for key in "${!PROJECT_TYPES[@]}"; do
        echo "  $i) ${PROJECT_TYPES[$key]}"
        type_map[$i]=$key
        ((i++))
    done
    
    echo ""
    read -p "選択 (1-$((i-1))): " type_choice
    
    if [[ -n "${type_map[$type_choice]}" ]]; then
        PROJECT_TYPE="${type_map[$type_choice]}"
    else
        echo -e "${RED}無効な選択です${NC}"
        exit 1
    fi
}

# 推奨チーム構成の決定
determine_team_composition() {
    # 基本チーム（必須）
    SELECTED_AGENTS=("president" "boss1")
    
    # 規模とタイプに基づいてチーム構成を決定
    case $PROJECT_SCALE in
        "small")
            case $PROJECT_TYPE in
                "web"|"mobile")
                    SELECTED_AGENTS+=("worker1" "worker2")
                    ;;
                "api"|"devops")
                    SELECTED_AGENTS+=("worker1" "integrator")
                    ;;
                "data")
                    SELECTED_AGENTS+=("worker1" "worker2")
                    ;;
                *)
                    SELECTED_AGENTS+=("worker1")
                    ;;
            esac
            ;;
            
        "medium")
            SELECTED_AGENTS+=("dispatcher")
            case $PROJECT_TYPE in
                "web"|"mobile")
                    SELECTED_AGENTS+=("ux_researcher" "worker1" "worker2" "worker3" "qa_tester")
                    ;;
                "api")
                    SELECTED_AGENTS+=("worker1" "worker2" "integrator" "qa_tester")
                    ;;
                "data")
                    SELECTED_AGENTS+=("market_analyst" "worker1" "worker2" "worker3")
                    ;;
                "devops")
                    SELECTED_AGENTS+=("worker1" "worker2" "integrator" "qa_tester")
                    ;;
                *)
                    SELECTED_AGENTS+=("worker1" "worker2" "worker3")
                    ;;
            esac
            ;;
            
        "large")
            # 大規模プロジェクトは全エージェントを推奨
            SELECTED_AGENTS=("president" "market_analyst" "ux_researcher" "boss1" "dispatcher" 
                           "worker1" "worker2" "worker3" "integrator" "qa_tester")
            ;;
    esac
}

# チーム構成の確認と調整
confirm_team_composition() {
    echo ""
    echo -e "${GREEN}📋 推奨チーム構成:${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for agent in "${SELECTED_AGENTS[@]}"; do
        IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
        printf "  %-15s - %s\n" "$agent" "$desc"
    done
    
    echo ""
    echo -e "${YELLOW}この構成でよろしいですか？${NC}"
    echo "  1) はい、この構成で進める"
    echo "  2) カスタマイズする"
    echo "  3) キャンセル"
    echo ""
    read -p "選択 (1-3): " confirm_choice
    
    case $confirm_choice in
        1) return 0 ;;
        2) customize_team ;;
        3) echo "キャンセルしました"; exit 0 ;;
        *) echo -e "${RED}無効な選択です${NC}"; exit 1 ;;
    esac
}

# チームのカスタマイズ
customize_team() {
    echo ""
    echo -e "${CYAN}🔧 チーム構成のカスタマイズ${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 現在の選択状態を表示
    for agent in president market_analyst ux_researcher boss1 dispatcher worker1 worker2 worker3 integrator qa_tester; do
        IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
        
        if [[ " ${SELECTED_AGENTS[@]} " =~ " ${agent} " ]]; then
            status="${GREEN}[✓]${NC}"
        else
            status="${RED}[ ]${NC}"
        fi
        
        printf "  %b %-15s - %s\n" "$status" "$agent" "$desc"
    done
    
    echo ""
    echo "追加/削除するエージェントを入力してください (カンマ区切り)"
    echo "例: market_analyst,ux_researcher,-worker3"
    echo "(- を付けると削除、付けないと追加)"
    read -p "> " custom_input
    
    # カスタマイズ処理
    IFS=',' read -ra CUSTOM_AGENTS <<< "$custom_input"
    for agent in "${CUSTOM_AGENTS[@]}"; do
        agent=$(echo "$agent" | xargs) # トリム
        
        if [[ $agent == -* ]]; then
            # 削除
            agent=${agent:1}
            SELECTED_AGENTS=("${SELECTED_AGENTS[@]/$agent}")
        else
            # 追加
            if [[ -n "${AGENT_CONFIGS[$agent]}" ]] && [[ ! " ${SELECTED_AGENTS[@]} " =~ " ${agent} " ]]; then
                SELECTED_AGENTS+=("$agent")
            fi
        fi
    done
    
    # 重複削除と並び替え
    SELECTED_AGENTS=($(echo "${SELECTED_AGENTS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
}

# tmuxセッション作成
create_tmux_sessions() {
    echo ""
    echo -e "${BLUE}🚀 tmuxセッションを作成中...${NC}"
    
    # 必要なセッションを特定
    declare -A REQUIRED_SESSIONS
    for agent in "${SELECTED_AGENTS[@]}"; do
        IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
        REQUIRED_SESSIONS[$session]=1
    done
    
    # 既存セッションをクリーンアップ
    for session in "${!REQUIRED_SESSIONS[@]}"; do
        if tmux has-session -t "$session" 2>/dev/null; then
            echo "既存の $session セッションを削除中..."
            tmux kill-session -t "$session"
        fi
    done
    
    # presidentセッション作成
    if [[ -n "${REQUIRED_SESSIONS[president]}" ]]; then
        echo "presidentセッションを作成中..."
        tmux new-session -d -s president -n "PRESIDENT"
        tmux send-keys -t president:0 "echo -e '👑 PRESIDENT - 統括責任者'" C-m
    fi
    
    # multiagentセッション作成
    if [[ -n "${REQUIRED_SESSIONS[multiagent]}" ]]; then
        echo "multiagentセッションを作成中..."
        tmux new-session -d -s multiagent
        
        # 必要なペインを作成
        local pane_count=1
        for i in {1..4}; do
            if [[ $i -gt 1 ]]; then
                tmux split-window -t multiagent
            fi
            
            # ペインのレイアウト調整
            if [[ $i -eq 2 ]]; then
                tmux select-layout -t multiagent main-horizontal
            elif [[ $i -eq 3 ]]; then
                tmux select-layout -t multiagent tiled
            fi
        done
        
        # 各ペインにラベルを設定
        for agent in "${SELECTED_AGENTS[@]}"; do
            IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
            if [[ $session == "multiagent" ]]; then
                case $agent in
                    "boss1")
                        tmux send-keys -t multiagent:0.0 "echo -e '🎯 BOSS1 - チームリーダー'" C-m
                        ;;
                    "worker1")
                        tmux send-keys -t multiagent:0.1 "echo -e '👷 WORKER1 - 実行担当A'" C-m
                        ;;
                    "worker2")
                        tmux send-keys -t multiagent:0.2 "echo -e '👷 WORKER2 - 実行担当B'" C-m
                        ;;
                    "worker3")
                        tmux send-keys -t multiagent:0.3 "echo -e '👷 WORKER3 - 実行担当C'" C-m
                        ;;
                    "dispatcher")
                        tmux send-keys -t multiagent:1.0 "echo -e '🎯 DISPATCHER - タスク割り当て'" C-m
                        ;;
                esac
            fi
        done
    fi
    
    # specialistセッション作成
    if [[ -n "${REQUIRED_SESSIONS[specialist]}" ]]; then
        echo "specialistセッションを作成中..."
        tmux new-session -d -s specialist
        
        # 必要なペインを作成
        local specialist_count=0
        for agent in "${SELECTED_AGENTS[@]}"; do
            IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
            if [[ $session == "specialist" ]]; then
                if [[ $specialist_count -gt 0 ]]; then
                    tmux split-window -t specialist
                fi
                ((specialist_count++))
                
                # レイアウト調整
                if [[ $specialist_count -eq 2 ]]; then
                    tmux select-layout -t specialist even-horizontal
                elif [[ $specialist_count -gt 2 ]]; then
                    tmux select-layout -t specialist tiled
                fi
            fi
        done
        
        # 各ペインにラベルを設定
        for agent in "${SELECTED_AGENTS[@]}"; do
            IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
            if [[ $session == "specialist" ]]; then
                case $agent in
                    "market_analyst")
                        tmux send-keys -t specialist:0.0 "echo -e '📊 MARKET_ANALYST - 市場分析'" C-m
                        ;;
                    "ux_researcher")
                        tmux send-keys -t specialist:0.1 "echo -e '👥 UX_RESEARCHER - UX調査'" C-m
                        ;;
                    "integrator")
                        tmux send-keys -t specialist:1.0 "echo -e '🔧 INTEGRATOR - 統合担当'" C-m
                        ;;
                    "qa_tester")
                        tmux send-keys -t specialist:1.1 "echo -e '🧪 QA_TESTER - 品質保証'" C-m
                        ;;
                esac
            fi
        done
    fi
    
    echo -e "${GREEN}✅ セッション作成完了！${NC}"
}

# プロジェクト設定ファイルの作成
create_project_config() {
    echo ""
    echo -e "${BLUE}📝 プロジェクト設定を保存中...${NC}"
    
    mkdir -p config
    
    cat > config/team_config.json << EOF
{
  "project": {
    "scale": "$PROJECT_SCALE",
    "type": "$PROJECT_TYPE",
    "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  },
  "team": {
    "agents": [
$(for i in "${!SELECTED_AGENTS[@]}"; do
    agent="${SELECTED_AGENTS[$i]}"
    IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
    if [[ $i -eq $((${#SELECTED_AGENTS[@]} - 1)) ]]; then
        echo "      {\"name\": \"$agent\", \"session\": \"$session\", \"pane\": \"$pane\", \"layer\": \"$layer\", \"description\": \"$desc\"}"
    else
        echo "      {\"name\": \"$agent\", \"session\": \"$session\", \"pane\": \"$pane\", \"layer\": \"$layer\", \"description\": \"$desc\"},"
    fi
done)
    ]
  }
}
EOF
    
    echo -e "${GREEN}✅ 設定ファイル作成完了: config/team_config.json${NC}"
}

# 起動手順の表示
show_launch_instructions() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 AIエージェントチームの準備が完了しました！${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}📌 起動方法:${NC}"
    echo ""
    
    # セッションごとに起動コマンドを表示
    declare -A SESSION_SHOWN
    for agent in "${SELECTED_AGENTS[@]}"; do
        IFS=':' read -r session pane layer desc <<< "${AGENT_CONFIGS[$agent]}"
        
        if [[ -z "${SESSION_SHOWN[$session]}" ]]; then
            SESSION_SHOWN[$session]=1
            echo -e "${CYAN}【$session セッション】${NC}"
            
            # セッション内のエージェントを表示
            for a in "${SELECTED_AGENTS[@]}"; do
                IFS=':' read -r s p l d <<< "${AGENT_CONFIGS[$a]}"
                if [[ $s == $session ]]; then
                    echo "  - $a ($d)"
                fi
            done
            
            echo -e "  ${GREEN}起動コマンド:${NC} tmux attach -t $session"
            echo ""
        fi
    done
    
    echo -e "${YELLOW}📌 エージェント間の通信:${NC}"
    echo "  ./agent-send.sh [エージェント名] \"メッセージ\""
    echo ""
    echo "  例: ./agent-send.sh boss1 \"プロジェクトを開始してください\""
    echo ""
    echo -e "${YELLOW}📌 利用可能なエージェント一覧:${NC}"
    echo "  ./agent-send.sh --list"
    echo ""
    echo -e "${BLUE}💡 ヒント: 各tmuxセッションで 'tmux list-panes' を実行すると、${NC}"
    echo -e "${BLUE}   ペインの配置を確認できます。${NC}"
}

# メイン処理
main() {
    show_header
    select_project_scale
    select_project_type
    determine_team_composition
    confirm_team_composition
    create_tmux_sessions
    create_project_config
    show_launch_instructions
}

# スクリプト実行
main