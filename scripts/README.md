# science-db Scripts

このフォルダには、Copilot が作成した一括処理スクリプトと、マイグレーション用ツールが含まれます。

## 運用ルール

- 今後、一括処理で自動生成される作業用ファイルは原則としてすべて `scripts/` 配下に保存します。
- 問題・解答の本体 TeX は `university_exam/` に置き、`scripts/` には置きません。

## TeXコンパイル規約（共通ルール）

**engine / ドキュメントクラス**
- **エンジン**: `lualatex` を使用（日本語対応、フォント管理の効率化）
- **ドキュメントクラス**: `jlreq` を使用（日本語組版標準）
- **図形スタイル**: `standalone` を使用（TikZ図などの独立コンパイル用）

**例:**
```tex
\documentclass[lualatex,ja=standard]{jlreq}
\usepackage{tikz}  % 図形を使う場合

% または図形の独立コンパイル用
\documentclass[lualatex]{standalone}
\usepackage{tikz}
```

**注**: このルールは `math-db` と共通です。

## リポジトリ名変更メモ（2026-03-01）

- GitHub リポジトリ名は `physics-db` から `science-db` へ変更済み
- ローカル作業用フォルダは `C:\Users\selec\Documents\tex_all\science-db` を使用
- 詳細な引き継ぎは `HANDOVER_2026-03-01.md` を参照

## フォルダ構造

```
scripts/
├── compile/              # LaTeX コンパイルスクリプト
│   ├── compile_all.ps1            # 全TeXファイルをコンパイル
│   ├── compile_all_standalone.ps1 # スタンドアロン図をコンパイル
│   └── compile_all_tikz.ps1       # TikZ図をコンパイル
│
├── migration/            # ファイル移行・変換ツール
│   ├── analyze_tex_packages.ps1   # パッケージ使用状況解析
│   ├── cleanup_tikzlibraries.ps1  # TikZライブラリ最適化
│   ├── list_tikzlibraries.ps1     # TikZライブラリ一覧出力
│   ├── migrate_*.ps1              # 各種マイグレーションツール
│   └── *.md                       # 作業レポート・詳細記録
│
└── docs/                 # プロジェクトドキュメント
    ├── STRUCTURE.md               # プロジェクト全体構成
    └── HANDOVER_2026-03-01.md    # 引き継ぎメモ
```

## 詳細説明

詳細は [docs/STRUCTURE.md](docs/STRUCTURE.md) を参照してください。
