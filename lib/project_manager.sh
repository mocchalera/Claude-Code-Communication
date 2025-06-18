#!/bin/bash

# 🗂️ プロジェクト管理システム

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# ベースディレクトリ
PROJECTS_DIR="./projects"
CURRENT_PROJECT_FILE="./tmp/current_project.txt"

# プロジェクト初期化
init_project() {
    local project_name="$1"
    local project_type="${2:-general}"
    local description="${3:-}"
    
    if [[ -z "$project_name" ]]; then
        echo -e "${RED}エラー: プロジェクト名を指定してください${NC}"
        return 1
    fi
    
    # プロジェクトディレクトリ作成
    local project_path="$PROJECTS_DIR/$project_name"
    
    if [[ -d "$project_path" ]]; then
        echo -e "${YELLOW}警告: プロジェクト '$project_name' は既に存在します${NC}"
        read -p "上書きしますか？ (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            return 1
        fi
    fi
    
    echo -e "${BLUE}プロジェクト '$project_name' を初期化中...${NC}"
    
    # ディレクトリ構造作成
    mkdir -p "$project_path"/{docs,src,outputs,assets,tests}
    
    # プロジェクトメタデータ作成
    cat > "$project_path/PROJECT.yaml" << EOF
project:
  name: "$project_name"
  type: "$project_type"
  description: "$description"
  created_at: "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  status: "active"
  
structure:
  docs: "プロジェクトコンテキスト・仕様書"
  src: "ソースコード"
  outputs: "生成された成果物"
  assets: "画像・リソースファイル"
  tests: "テストコード"
  
team:
  lead: "PRESIDENT"
  members: []
  
context_files:
  - docs/requirements.md
  - docs/specifications.md
  - docs/architecture.md
EOF

    # 基本ドキュメントテンプレート作成
    create_context_templates "$project_path"
    
    # 現在のプロジェクトとして設定
    echo "$project_name" > "$CURRENT_PROJECT_FILE"
    
    echo -e "${GREEN}✅ プロジェクト '$project_name' を初期化しました${NC}"
    echo -e "${GREEN}   パス: $project_path${NC}"
}

# コンテキストテンプレート作成
create_context_templates() {
    local project_path="$1"
    
    # 要件定義書テンプレート
    cat > "$project_path/docs/requirements.md" << 'EOF'
# 要件定義書

## プロジェクト概要
[プロジェクトの背景と目的を記載]

## ビジネス要件
### 目標
- [ビジネス目標1]
- [ビジネス目標2]

### 成功指標
- [KPI1]
- [KPI2]

## 機能要件
### 必須機能
1. [機能1]
2. [機能2]

### オプション機能
1. [機能1]
2. [機能2]

## 非機能要件
### パフォーマンス
- [要件]

### セキュリティ
- [要件]

### 可用性
- [要件]

## 制約事項
- [技術的制約]
- [予算的制約]
- [時間的制約]

## ステークホルダー
- [ステークホルダー1]: [役割と期待]
- [ステークホルダー2]: [役割と期待]
EOF

    # 仕様書テンプレート
    cat > "$project_path/docs/specifications.md" << 'EOF'
# 技術仕様書

## システム概要
[システムの全体像と主要コンポーネント]

## 技術スタック
### フロントエンド
- フレームワーク: 
- 言語: 
- ビルドツール: 

### バックエンド
- フレームワーク: 
- 言語: 
- データベース: 

### インフラ
- ホスティング: 
- CI/CD: 
- モニタリング: 

## API仕様
### エンドポイント一覧
| メソッド | パス | 説明 |
|----------|------|------|
| GET | /api/v1/... | ... |

## データモデル
### エンティティ
```
[エンティティ定義]
```

## セキュリティ
### 認証・認可
[認証方式の説明]

### データ保護
[暗号化・セキュリティ対策]
EOF

    # アーキテクチャ文書テンプレート
    cat > "$project_path/docs/architecture.md" << 'EOF'
# アーキテクチャ設計書

## システムアーキテクチャ
[アーキテクチャ図]

## コンポーネント設計
### フロントエンド
[コンポーネント構成]

### バックエンド
[モジュール構成]

## データフロー
[データの流れ図]

## 設計原則
- [原則1]
- [原則2]

## 技術的決定事項
### 選定理由
[技術選定の根拠]

### トレードオフ
[検討したトレードオフ]
EOF

    # コンテキストREADME
    cat > "$project_path/docs/README.md" << 'EOF'
# プロジェクトコンテキスト

このディレクトリには、プロジェクトの正確な理解と実装のために必要なすべてのコンテキスト情報が含まれています。

## 重要なドキュメント
- `requirements.md` - ビジネス要件と機能要件
- `specifications.md` - 技術仕様
- `architecture.md` - システム設計

## ガイドライン
AIエージェントがハルシネーションを防ぎ、正確な実装を行うために、これらのドキュメントを常に参照してください。

## 更新履歴
- [日付] - 初期作成
EOF
}

# プロジェクト切り替え
switch_project() {
    local project_name="$1"
    local project_path="$PROJECTS_DIR/$project_name"
    
    if [[ ! -d "$project_path" ]]; then
        echo -e "${RED}エラー: プロジェクト '$project_name' が見つかりません${NC}"
        return 1
    fi
    
    echo "$project_name" > "$CURRENT_PROJECT_FILE"
    echo -e "${GREEN}✅ プロジェクト '$project_name' に切り替えました${NC}"
    
    # プロジェクト情報表示
    show_project_info "$project_name"
}

# 現在のプロジェクト取得
get_current_project() {
    if [[ -f "$CURRENT_PROJECT_FILE" ]]; then
        cat "$CURRENT_PROJECT_FILE"
    else
        echo ""
    fi
}

# プロジェクトコンテキスト読み込み
load_project_context() {
    local project_name="${1:-$(get_current_project)}"
    
    if [[ -z "$project_name" ]]; then
        echo -e "${RED}エラー: プロジェクトが選択されていません${NC}"
        return 1
    fi
    
    local project_path="$PROJECTS_DIR/$project_name"
    local docs_path="$project_path/docs"
    
    echo -e "${BLUE}📚 プロジェクト '$project_name' のコンテキストを読み込み中...${NC}"
    echo ""
    
    # すべてのマークダウンファイルを読み込み
    for doc in "$docs_path"/*.md; do
        if [[ -f "$doc" ]]; then
            local filename=$(basename "$doc")
            echo -e "${YELLOW}=== $filename ===${NC}"
            cat "$doc"
            echo ""
        fi
    done
}

# プロジェクト一覧表示
list_projects() {
    echo -e "${BLUE}📋 利用可能なプロジェクト:${NC}"
    echo "=========================="
    
    local current_project=$(get_current_project)
    
    for project_dir in "$PROJECTS_DIR"/*; do
        if [[ -d "$project_dir" ]]; then
            local project_name=$(basename "$project_dir")
            local project_info=""
            
            if [[ -f "$project_dir/PROJECT.yaml" ]]; then
                local type=$(grep "type:" "$project_dir/PROJECT.yaml" | awk '{print $2}' | tr -d '"')
                local status=$(grep "status:" "$project_dir/PROJECT.yaml" | awk '{print $2}' | tr -d '"')
                project_info="[$type] - $status"
            fi
            
            if [[ "$project_name" == "$current_project" ]]; then
                echo -e "${GREEN}▶ $project_name${NC} $project_info"
            else
                echo "  $project_name $project_info"
            fi
        fi
    done
}

# プロジェクト情報表示
show_project_info() {
    local project_name="${1:-$(get_current_project)}"
    
    if [[ -z "$project_name" ]]; then
        echo -e "${RED}エラー: プロジェクトが選択されていません${NC}"
        return 1
    fi
    
    local project_path="$PROJECTS_DIR/$project_name"
    
    if [[ ! -f "$project_path/PROJECT.yaml" ]]; then
        echo -e "${RED}エラー: プロジェクト情報が見つかりません${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📊 プロジェクト情報: $project_name${NC}"
    echo "=================================="
    cat "$project_path/PROJECT.yaml"
}

# コンテキストファイル追加
add_context_file() {
    local project_name="${1:-$(get_current_project)}"
    local file_path="$2"
    local dest_name="${3:-$(basename "$file_path")}"
    
    if [[ -z "$project_name" ]]; then
        echo -e "${RED}エラー: プロジェクトが選択されていません${NC}"
        return 1
    fi
    
    if [[ ! -f "$file_path" ]]; then
        echo -e "${RED}エラー: ファイル '$file_path' が見つかりません${NC}"
        return 1
    fi
    
    local project_path="$PROJECTS_DIR/$project_name"
    local docs_path="$project_path/docs"
    
    cp "$file_path" "$docs_path/$dest_name"
    echo -e "${GREEN}✅ コンテキストファイル '$dest_name' を追加しました${NC}"
    
    # PROJECT.yamlを更新
    if ! grep -q "$dest_name" "$project_path/PROJECT.yaml"; then
        sed -i '' "/context_files:/a\\
  - docs/$dest_name" "$project_path/PROJECT.yaml"
    fi
}

# プロジェクトパス取得
get_project_path() {
    local project_name="${1:-$(get_current_project)}"
    
    if [[ -z "$project_name" ]]; then
        echo ""
        return 1
    fi
    
    echo "$PROJECTS_DIR/$project_name"
}

# CLIインターフェース
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "init")
            init_project "$2" "$3" "$4"
            ;;
        "switch")
            switch_project "$2"
            ;;
        "current")
            current=$(get_current_project)
            if [[ -n "$current" ]]; then
                echo "現在のプロジェクト: $current"
            else
                echo "プロジェクトが選択されていません"
            fi
            ;;
        "list")
            list_projects
            ;;
        "info")
            show_project_info "$2"
            ;;
        "context")
            load_project_context "$2"
            ;;
        "add-context")
            add_context_file "$2" "$3" "$4"
            ;;
        "path")
            get_project_path "$2"
            ;;
        *)
            echo "Usage: $0 {init|switch|current|list|info|context|add-context|path}"
            echo ""
            echo "Commands:"
            echo "  init <name> [type] [description]    - 新しいプロジェクトを初期化"
            echo "  switch <name>                       - プロジェクトを切り替え"
            echo "  current                             - 現在のプロジェクトを表示"
            echo "  list                                - プロジェクト一覧を表示"
            echo "  info [name]                         - プロジェクト情報を表示"
            echo "  context [name]                      - プロジェクトコンテキストを読み込み"
            echo "  add-context [project] <file> [name] - コンテキストファイルを追加"
            echo "  path [name]                         - プロジェクトパスを取得"
            ;;
    esac
fi