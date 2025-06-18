# Agent Communication System

## エージェント構成
### 戦略層
- **PRESIDENT** (別セッション): 統括責任者
- **market_analyst** (specialist:0.0): 市場分析
- **ux_researcher** (specialist:0.1): UXリサーチ

### 管理層
- **boss1** (multiagent:0.0): チームリーダー
- **dispatcher** (multiagent:1.0): タスク割り当て

### 実行層
- **worker1,2,3** (multiagent:0.1-3): 実行担当
- **ui_ux_designer**: UI/UXデザイン専門

### 品質保証層
- **integrator** (specialist:1.0): 統合担当
- **qa_tester** (specialist:1.1): 品質保証

## あなたの役割
- **PRESIDENT**: @instructions/president.md
- **boss1**: @instructions/boss.md
- **worker1,2,3**: @instructions/worker.md
- **dispatcher**: @instructions/dispatcher.md
- **market_analyst**: @instructions/market_analyst.md
- **ux_researcher**: @instructions/ux_researcher.md
- **ui_ux_designer**: @instructions/ui_ux_designer.md
- **integrator**: @instructions/integrator.md
- **qa_tester**: @instructions/qa_tester.md

## デザイン・UI/UXタスクの特別ルール
**重要**: デザイン、UI、UX関連のタスクを受けた場合は、必ず以下を実行：
```bash
# デザインガイドライン参照（必須）
cat ./docs/デザイン実装ガイドライン.md
```
このガイドラインには設計哲学、詳細仕様、実装プロセスが含まれています。

## メッセージ送信
```bash
./agent-send.sh [相手] "[メッセージ]"
```

## プロジェクトコンテキスト管理
**重要**: すべてのプロジェクトは `/projects/[プロジェクト名]` に保存され、各プロジェクトの `/docs` フォルダにコンテキスト情報が含まれています。

### プロジェクト開始時の必須アクション
```bash
# 現在のプロジェクトコンテキストを読み込む
source ./lib/project_manager.sh
load_project_context

# 特定のプロジェクトのコンテキストを読み込む
./lib/project_manager.sh context [プロジェクト名]
```

### プロジェクト構造
```
/projects/[プロジェクト名]/
├── docs/           # コンテキスト情報（要件、仕様、設計）
├── src/            # ソースコード
├── outputs/        # 生成された成果物
├── assets/         # 画像・リソース
└── tests/          # テストコード
```

**ハルシネーション防止**: 実装前に必ず `docs/` 内のコンテキストファイルを参照してください。

## 基本フロー
PRESIDENT → boss1 → workers → boss1 → PRESIDENT 