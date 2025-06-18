#!/bin/bash

# 🚀 プロジェクト初期化ウィザード

# カラー定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# ライブラリ読み込み
source ./lib/project_manager.sh

# ヘッダー表示
show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        🚀 プロジェクト初期化ウィザード         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

# プロジェクト情報入力
get_project_info() {
    echo -e "${YELLOW}📋 新しいプロジェクトを作成します${NC}"
    echo ""
    
    # プロジェクト名
    while true; do
        read -p "プロジェクト名: " PROJECT_NAME
        if [[ -n "$PROJECT_NAME" ]]; then
            break
        else
            echo -e "${RED}プロジェクト名は必須です${NC}"
        fi
    done
    
    # プロジェクトタイプ
    echo ""
    echo -e "${YELLOW}プロジェクトタイプを選択してください:${NC}"
    echo "1) web        - Webアプリケーション"
    echo "2) api        - API/バックエンド"
    echo "3) mobile     - モバイルアプリ"
    echo "4) data       - データ分析・AI/ML"
    echo "5) cli        - CLIツール"
    echo "6) general    - 汎用プロジェクト"
    echo ""
    
    read -p "選択 (1-6) [6]: " TYPE_CHOICE
    case $TYPE_CHOICE in
        1) PROJECT_TYPE="web" ;;
        2) PROJECT_TYPE="api" ;;
        3) PROJECT_TYPE="mobile" ;;
        4) PROJECT_TYPE="data" ;;
        5) PROJECT_TYPE="cli" ;;
        *) PROJECT_TYPE="general" ;;
    esac
    
    # プロジェクト説明
    echo ""
    read -p "プロジェクトの説明 (任意): " PROJECT_DESC
}

# コンテキスト情報入力
setup_context() {
    echo ""
    echo -e "${YELLOW}📄 プロジェクトコンテキストを設定します${NC}"
    echo ""
    
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    
    # 要件定義の詳細入力
    echo -e "${BLUE}要件定義を入力してください:${NC}"
    echo "1) エディタで編集する"
    echo "2) 既存ファイルをインポート"
    echo "3) 後で設定する"
    echo ""
    
    read -p "選択 (1-3) [3]: " REQ_CHOICE
    case $REQ_CHOICE in
        1)
            ${EDITOR:-vi} "$project_path/docs/requirements.md"
            ;;
        2)
            read -p "インポートするファイルのパス: " REQ_FILE
            if [[ -f "$REQ_FILE" ]]; then
                cp "$REQ_FILE" "$project_path/docs/requirements.md"
                echo -e "${GREEN}✅ 要件定義をインポートしました${NC}"
            else
                echo -e "${RED}ファイルが見つかりません${NC}"
            fi
            ;;
        *)
            echo "要件定義は後で設定してください"
            ;;
    esac
    
    # ユーザーストーリー
    echo ""
    echo -e "${BLUE}主要なユーザーストーリーを入力してください (空行で終了):${NC}"
    echo "例: ユーザーとして、商品を検索できる"
    echo ""
    
    local stories=""
    while true; do
        read -p "> " story
        if [[ -z "$story" ]]; then
            break
        fi
        stories="${stories}- ${story}\n"
    done
    
    if [[ -n "$stories" ]]; then
        echo -e "\n## ユーザーストーリー\n${stories}" >> "$project_path/docs/requirements.md"
    fi
}

# チーム構成の提案
suggest_team() {
    echo ""
    echo -e "${YELLOW}👥 推奨チーム構成${NC}"
    echo ""
    
    case $PROJECT_TYPE in
        "web")
            echo "推奨エージェント:"
            echo "- president (統括)"
            echo "- ux_researcher (UX調査)"
            echo "- ui_ux_designer (デザイン)"
            echo "- boss1 + workers (実装)"
            echo "- integrator + qa_tester (品質保証)"
            ;;
        "api")
            echo "推奨エージェント:"
            echo "- president (統括)"
            echo "- boss1 + workers (実装)"
            echo "- integrator + qa_tester (品質保証)"
            ;;
        "data")
            echo "推奨エージェント:"
            echo "- president (統括)"
            echo "- market_analyst (データ分析)"
            echo "- boss1 + workers (実装)"
            ;;
        *)
            echo "プロジェクトに応じてチームを構成してください"
            ;;
    esac
}

# 初期タスクの生成
generate_initial_tasks() {
    echo ""
    echo -e "${YELLOW}📝 初期タスクを生成しています...${NC}"
    
    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    
    cat > "$project_path/docs/initial_tasks.md" << EOF
# 初期タスクリスト

## フェーズ1: 要件分析と設計
- [ ] 要件定義書の詳細化
- [ ] 技術仕様の策定
- [ ] アーキテクチャ設計

## フェーズ2: 環境構築
- [ ] 開発環境のセットアップ
- [ ] リポジトリ構造の作成
- [ ] CI/CDパイプラインの設定

## フェーズ3: 実装
- [ ] コア機能の実装
- [ ] テストの作成
- [ ] ドキュメントの作成

## フェーズ4: 品質保証
- [ ] 統合テスト
- [ ] パフォーマンステスト
- [ ] セキュリティ監査
EOF
    
    echo -e "${GREEN}✅ 初期タスクリストを生成しました${NC}"
}

# 次のステップ表示
show_next_steps() {
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 プロジェクト '$PROJECT_NAME' の初期化が完了しました！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}📌 次のステップ:${NC}"
    echo ""
    echo "1. プロジェクトディレクトリを確認:"
    echo -e "   ${BLUE}cd $PROJECTS_DIR/$PROJECT_NAME${NC}"
    echo ""
    echo "2. コンテキストを確認・編集:"
    echo -e "   ${BLUE}vi $PROJECTS_DIR/$PROJECT_NAME/docs/requirements.md${NC}"
    echo ""
    echo "3. プロジェクトを開始:"
    echo -e "   ${BLUE}./agent-send.sh president \"新しいプロジェクト '$PROJECT_NAME' を開始してください\"${NC}"
    echo ""
    echo "4. コンテキストを読み込む:"
    echo -e "   ${BLUE}./lib/project_manager.sh context $PROJECT_NAME${NC}"
    echo ""
}

# メイン処理
main() {
    show_header
    get_project_info
    
    # プロジェクト初期化
    init_project "$PROJECT_NAME" "$PROJECT_TYPE" "$PROJECT_DESC"
    
    setup_context
    generate_initial_tasks
    suggest_team
    show_next_steps
}

# 実行
main