#!/bin/bash

# 📊 進捗管理システムライブラリ

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 進捗ファイルパス
PROGRESS_FILE="./tmp/progress.json"
PROGRESS_DIR="./tmp"

# 初期化
init_progress_system() {
    mkdir -p "$PROGRESS_DIR"
    
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        cat > "$PROGRESS_FILE" << 'EOF'
{
  "project": {
    "name": "",
    "start_time": "",
    "status": "active"
  },
  "tasks": {},
  "workers": {},
  "metrics": {
    "total_tasks": 0,
    "completed_tasks": 0,
    "in_progress_tasks": 0,
    "pending_tasks": 0,
    "failed_tasks": 0
  }
}
EOF
    fi
}

# プロジェクト初期化
init_project() {
    local project_name="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg name "$project_name" \
       --arg time "$timestamp" \
       '.project.name = $name | .project.start_time = $time' \
       "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
}

# タスク作成
create_task() {
    local task_id="$1"
    local task_name="$2"
    local assigned_to="$3"
    local priority="${4:-medium}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg id "$task_id" \
       --arg name "$task_name" \
       --arg worker "$assigned_to" \
       --arg prio "$priority" \
       --arg time "$timestamp" \
       '.tasks[$id] = {
          "name": $name,
          "status": "pending",
          "assigned_to": $worker,
          "priority": $prio,
          "created_at": $time,
          "started_at": null,
          "completed_at": null,
          "progress_percentage": 0,
          "notes": []
        }' \
       "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
    
    update_metrics
}

# タスクステータス更新
update_task_status() {
    local task_id="$1"
    local new_status="$2"
    local progress="${3:-0}"
    local note="${4:-}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # ステータスに応じてタイムスタンプを更新
    case "$new_status" in
        "in_progress")
            jq --arg id "$task_id" \
               --arg status "$new_status" \
               --arg time "$timestamp" \
               --arg prog "$progress" \
               '.tasks[$id].status = $status | 
                .tasks[$id].started_at = $time |
                .tasks[$id].progress_percentage = ($prog | tonumber)' \
               "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp"
            ;;
        "completed")
            jq --arg id "$task_id" \
               --arg status "$new_status" \
               --arg time "$timestamp" \
               '.tasks[$id].status = $status | 
                .tasks[$id].completed_at = $time |
                .tasks[$id].progress_percentage = 100' \
               "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp"
            ;;
        "failed")
            jq --arg id "$task_id" \
               --arg status "$new_status" \
               --arg time "$timestamp" \
               --arg prog "$progress" \
               '.tasks[$id].status = $status | 
                .tasks[$id].completed_at = $time |
                .tasks[$id].progress_percentage = ($prog | tonumber)' \
               "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp"
            ;;
        *)
            jq --arg id "$task_id" \
               --arg status "$new_status" \
               --arg prog "$progress" \
               '.tasks[$id].status = $status | 
                .tasks[$id].progress_percentage = ($prog | tonumber)' \
               "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp"
            ;;
    esac
    
    mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
    
    # ノート追加
    if [[ -n "$note" ]]; then
        add_task_note "$task_id" "$note"
    fi
    
    update_metrics
    update_worker_stats
}

# タスクノート追加
add_task_note() {
    local task_id="$1"
    local note="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq --arg id "$task_id" \
       --arg note "$note" \
       --arg time "$timestamp" \
       '.tasks[$id].notes += [{"timestamp": $time, "note": $note}]' \
       "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
}

# Worker統計更新
update_worker_stats() {
    # 各workerのタスク統計を計算
    local workers=$(jq -r '.tasks | to_entries[] | .value.assigned_to' "$PROGRESS_FILE" | sort -u)
    
    for worker in $workers; do
        local total=$(jq --arg w "$worker" '[.tasks | to_entries[] | select(.value.assigned_to == $w)] | length' "$PROGRESS_FILE")
        local completed=$(jq --arg w "$worker" '[.tasks | to_entries[] | select(.value.assigned_to == $w and .value.status == "completed")] | length' "$PROGRESS_FILE")
        local in_progress=$(jq --arg w "$worker" '[.tasks | to_entries[] | select(.value.assigned_to == $w and .value.status == "in_progress")] | length' "$PROGRESS_FILE")
        local failed=$(jq --arg w "$worker" '[.tasks | to_entries[] | select(.value.assigned_to == $w and .value.status == "failed")] | length' "$PROGRESS_FILE")
        
        jq --arg w "$worker" \
           --arg total "$total" \
           --arg completed "$completed" \
           --arg in_progress "$in_progress" \
           --arg failed "$failed" \
           '.workers[$w] = {
              "total_tasks": ($total | tonumber),
              "completed_tasks": ($completed | tonumber),
              "in_progress_tasks": ($in_progress | tonumber),
              "failed_tasks": ($failed | tonumber),
              "success_rate": (if ($total | tonumber) > 0 then (($completed | tonumber) / ($total | tonumber) * 100) else 0 end)
            }' \
           "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
    done
}

# メトリクス更新
update_metrics() {
    local total=$(jq '.tasks | length' "$PROGRESS_FILE")
    local completed=$(jq '[.tasks | to_entries[] | select(.value.status == "completed")] | length' "$PROGRESS_FILE")
    local in_progress=$(jq '[.tasks | to_entries[] | select(.value.status == "in_progress")] | length' "$PROGRESS_FILE")
    local pending=$(jq '[.tasks | to_entries[] | select(.value.status == "pending")] | length' "$PROGRESS_FILE")
    local failed=$(jq '[.tasks | to_entries[] | select(.value.status == "failed")] | length' "$PROGRESS_FILE")
    
    jq --arg total "$total" \
       --arg completed "$completed" \
       --arg in_progress "$in_progress" \
       --arg pending "$pending" \
       --arg failed "$failed" \
       '.metrics = {
          "total_tasks": ($total | tonumber),
          "completed_tasks": ($completed | tonumber),
          "in_progress_tasks": ($in_progress | tonumber),
          "pending_tasks": ($pending | tonumber),
          "failed_tasks": ($failed | tonumber),
          "completion_rate": (if ($total | tonumber) > 0 then (($completed | tonumber) / ($total | tonumber) * 100) else 0 end)
        }' \
       "$PROGRESS_FILE" > "$PROGRESS_FILE.tmp" && mv "$PROGRESS_FILE.tmp" "$PROGRESS_FILE"
}

# 進捗レポート生成
generate_progress_report() {
    local format="${1:-summary}"
    
    case "$format" in
        "summary")
            echo -e "${GREEN}📊 プロジェクト進捗サマリー${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            local project_name=$(jq -r '.project.name' "$PROGRESS_FILE")
            local completion_rate=$(jq -r '.metrics.completion_rate' "$PROGRESS_FILE")
            
            echo "プロジェクト: $project_name"
            echo -e "完了率: ${GREEN}${completion_rate}%${NC}"
            echo ""
            
            echo "タスク統計:"
            jq -r '.metrics | "  総タスク数: \(.total_tasks)\n  完了: \(.completed_tasks)\n  進行中: \(.in_progress_tasks)\n  保留: \(.pending_tasks)\n  失敗: \(.failed_tasks)"' "$PROGRESS_FILE"
            ;;
            
        "detailed")
            echo -e "${GREEN}📊 詳細進捗レポート${NC}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            # タスクごとの詳細
            echo -e "\n${YELLOW}タスク詳細:${NC}"
            jq -r '.tasks | to_entries[] | 
                   "\(.key): \(.value.name)\n  状態: \(.value.status)\n  担当: \(.value.assigned_to)\n  進捗: \(.value.progress_percentage)%\n"' \
                   "$PROGRESS_FILE"
            
            # Worker統計
            echo -e "\n${YELLOW}Worker統計:${NC}"
            jq -r '.workers | to_entries[] | 
                   "\(.key):\n  総タスク: \(.value.total_tasks)\n  完了: \(.value.completed_tasks)\n  成功率: \(.value.success_rate)%\n"' \
                   "$PROGRESS_FILE"
            ;;
            
        "json")
            jq '.' "$PROGRESS_FILE"
            ;;
    esac
}

# ガントチャート風表示
show_gantt_view() {
    echo -e "${GREEN}📊 タスク進捗ビュー${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    jq -r '.tasks | to_entries[] | 
           "\(.key): \(.value.name) [\(.value.assigned_to)]"' "$PROGRESS_FILE" | \
    while read -r line; do
        local task_id=$(echo "$line" | cut -d: -f1)
        local progress=$(jq -r --arg id "$task_id" '.tasks[$id].progress_percentage' "$PROGRESS_FILE")
        local status=$(jq -r --arg id "$task_id" '.tasks[$id].status' "$PROGRESS_FILE")
        
        printf "%-40s " "$line"
        
        # プログレスバー表示
        local bar_length=20
        local filled=$((progress * bar_length / 100))
        local empty=$((bar_length - filled))
        
        case "$status" in
            "completed")
                echo -ne "${GREEN}"
                ;;
            "in_progress")
                echo -ne "${YELLOW}"
                ;;
            "failed")
                echo -ne "${RED}"
                ;;
            *)
                echo -ne "${NC}"
                ;;
        esac
        
        echo -n "["
        for ((i=0; i<filled; i++)); do echo -n "█"; done
        for ((i=0; i<empty; i++)); do echo -n "░"; done
        echo -e "] ${progress}%${NC}"
    done
}

# エクスポート機能
export_progress() {
    local export_format="${1:-json}"
    local output_file="${2:-./progress_export_$(date +%Y%m%d_%H%M%S)}"
    
    case "$export_format" in
        "json")
            cp "$PROGRESS_FILE" "${output_file}.json"
            echo "Progress exported to: ${output_file}.json"
            ;;
        "csv")
            echo "task_id,task_name,status,assigned_to,progress,priority" > "${output_file}.csv"
            jq -r '.tasks | to_entries[] | 
                   "\(.key),\(.value.name),\(.value.status),\(.value.assigned_to),\(.value.progress_percentage),\(.value.priority)"' \
                   "$PROGRESS_FILE" >> "${output_file}.csv"
            echo "Progress exported to: ${output_file}.csv"
            ;;
        "markdown")
            {
                echo "# プロジェクト進捗レポート"
                echo ""
                echo "## 概要"
                jq -r '"- プロジェクト名: \(.project.name)\n- 開始日時: \(.project.start_time)\n- 完了率: \(.metrics.completion_rate)%"' "$PROGRESS_FILE"
                echo ""
                echo "## タスク一覧"
                echo "| ID | タスク名 | 状態 | 担当者 | 進捗 |"
                echo "|---|---------|------|--------|------|"
                jq -r '.tasks | to_entries[] | 
                       "| \(.key) | \(.value.name) | \(.value.status) | \(.value.assigned_to) | \(.value.progress_percentage)% |"' \
                       "$PROGRESS_FILE"
            } > "${output_file}.md"
            echo "Progress exported to: ${output_file}.md"
            ;;
    esac
}

# CLIインターフェース
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "init")
            init_progress_system
            init_project "${2:-New Project}"
            echo "Progress system initialized"
            ;;
        "create-task")
            init_progress_system
            create_task "$2" "$3" "$4" "${5:-medium}"
            echo "Task created: $2"
            ;;
        "update")
            update_task_status "$2" "$3" "${4:-0}" "${5:-}"
            echo "Task $2 updated to $3"
            ;;
        "report")
            generate_progress_report "${2:-summary}"
            ;;
        "gantt")
            show_gantt_view
            ;;
        "export")
            export_progress "${2:-json}" "${3:-}"
            ;;
        *)
            echo "Usage: $0 {init|create-task|update|report|gantt|export}"
            echo ""
            echo "Commands:"
            echo "  init [project_name]                          - Initialize progress system"
            echo "  create-task <id> <name> <assignee> [priority] - Create new task"
            echo "  update <id> <status> [progress] [note]       - Update task status"
            echo "  report [summary|detailed|json]               - Generate progress report"
            echo "  gantt                                        - Show gantt chart view"
            echo "  export [json|csv|markdown] [filename]        - Export progress data"
            ;;
    esac
fi